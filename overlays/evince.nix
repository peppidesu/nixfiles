# Animated (smooth) wheel scrolling for evince 48.x.
#   nixpkgs.overlays = [ (import ./overlays/evince-smooth-scroll) ];
final: prev:
let
  # C: animation helpers, inserted immediately before ev_view_scroll_event().
  helpers = prev.writeText "evince-smooth-scroll-helpers.c" ''
    /* ---- smooth scrolling: animate wheel notches instead of jumping ---- */
    #define EV_SMOOTH_SCROLL_DURATION (180 * 1000) /* microseconds */
    #define EV_SMOOTH_SCROLL_MIN_DELTA 1.0

    typedef struct {
        EvView   *view;
        guint     tick_id;
        gboolean  horizontal;
        gdouble   start;
        gdouble   target;
        gint64    start_time;
    } EvSmoothScroll;

    static void
    ev_smooth_scroll_limits (GtkAdjustment *adjustment,
                             gdouble       *lower,
                             gdouble       *max_value)
    {
        gdouble upper = gtk_adjustment_get_upper (adjustment);
        gdouble page_size = gtk_adjustment_get_page_size (adjustment);

        *lower = gtk_adjustment_get_lower (adjustment);
        *max_value = MAX (*lower, upper - page_size);
    }

    static GtkAdjustment *
    ev_smooth_scroll_adjustment (EvSmoothScroll *s)
    {
        return s->horizontal ? s->view->hadjustment : s->view->vadjustment;
    }

    static gboolean
    ev_view_smooth_scroll_tick (GtkWidget     *widget,
                                GdkFrameClock *frame_clock,
                                gpointer       user_data)
    {
        EvSmoothScroll *s = user_data;
        GtkAdjustment *adjustment;
        gdouble lower, max_value, value, progress;
        gint64 now;

        (void) widget;
        (void) frame_clock;

        adjustment = ev_smooth_scroll_adjustment (s);
        if (adjustment == NULL) {
            s->tick_id = 0;
            return G_SOURCE_REMOVE;
        }

        ev_smooth_scroll_limits (adjustment, &lower, &max_value);

        now = g_get_monotonic_time ();
        progress = (now - s->start_time) / (gdouble) EV_SMOOTH_SCROLL_DURATION;

        if (progress >= 1.0) {
            s->tick_id = 0;
            gtk_adjustment_set_value (adjustment, CLAMP (s->target, lower, max_value));
            return G_SOURCE_REMOVE;
        }

        progress = 1.0 - pow (1.0 - progress, 3.0); /* ease-out cubic */
        value = s->start + (s->target - s->start) * progress;

        gtk_adjustment_set_value (adjustment, CLAMP (value, lower, max_value));

        return G_SOURCE_CONTINUE;
    }

    static gboolean
    ev_view_smooth_scroll_by (EvView *view, GtkAdjustment *adjustment, gdouble delta)
    {
        EvSmoothScroll *s;
        gdouble value, lower, max_value, base, target;

        if (adjustment == NULL || delta == 0.0)
            return FALSE;

        value = gtk_adjustment_get_value (adjustment);
        ev_smooth_scroll_limits (adjustment, &lower, &max_value);

        /* Nothing to scroll here: let the caller fall through to its own
         * page-flipping logic. */
        if (max_value <= lower)
            return FALSE;

        s = g_object_get_data (G_OBJECT (view), "ev-smooth-scroll");
        if (s == NULL) {
            s = g_new0 (EvSmoothScroll, 1);
            s->view = view;
            g_object_set_data_full (G_OBJECT (view), "ev-smooth-scroll",
                                    s, g_free);
        }

        /* Notches arriving mid-animation accumulate on the target instead of
         * restarting from the current (already moving) value. */
        base = s->tick_id != 0 ? s->target : value;
        target = CLAMP (base + delta, lower, max_value);

        if (target == value)
            return s->tick_id != 0;

        if (s->tick_id != 0)
            gtk_widget_remove_tick_callback (GTK_WIDGET (view), s->tick_id);

        s->horizontal = adjustment == view->hadjustment;
        s->start = value;
        s->target = target;
        s->start_time = g_get_monotonic_time ();
        s->tick_id = gtk_widget_add_tick_callback (GTK_WIDGET (view),
                                                   ev_view_smooth_scroll_tick,
                                                   s, NULL);

        return TRUE;
    }
  '';

  # C: the hook, inserted into ev_view_scroll_event() (gets one leading tab).
  hook = prev.writeText "evince-smooth-scroll-hook.c" ''
    /* Animate wheel scrolling instead of jumping a whole step per notch.
     * Only whole-notch events are animated; fine-grained touchpad deltas and
     * Ctrl/Shift-modified events keep their native behaviour. */
    if (state == 0) {
        gdouble delta = 0.0;

        switch (event->direction) {
        case GDK_SCROLL_UP:
            delta = -1.0;
            break;
        case GDK_SCROLL_DOWN:
            delta = 1.0;
            break;
        case GDK_SCROLL_SMOOTH:
            if (fabs (event->delta_y) >= EV_SMOOTH_SCROLL_MIN_DELTA)
                delta = event->delta_y;
            break;
        default:
            break;
        }

        if (delta != 0.0) {
            gdouble step = gtk_adjustment_get_step_increment (view->vadjustment);

            if (step <= 0.0)
                step = gtk_adjustment_get_page_increment (view->vadjustment) / 10.0;

            if (ev_view_smooth_scroll_by (view, view->vadjustment, delta * step))
                return TRUE;
        }
    }
  '';

  # Anchor-based patcher: no line numbers, asserts uniqueness, fails loudly.
  patcher = prev.writeText "evince-smooth-scroll.py" ''
    import sys

    src_path, helpers_path, hook_path = sys.argv[1], sys.argv[2], sys.argv[3]

    with open (src_path, encoding="utf-8") as f:
        src = f.read ()

    with open (helpers_path, encoding="utf-8") as f:
        helpers = f.read ().strip ("\n")

    with open (hook_path, encoding="utf-8") as f:
        hook = f.read ().strip ("\n")

    hook = "\n".join (("\t" + l) if l else l for l in hook.split ("\n"))

    if "ev_view_smooth_scroll_by" in src:
        sys.exit ("evince-smooth-scroll: ev-view.c already patched")

    def unique (haystack, needle, what):
        n = haystack.count (needle)
        if n != 1:
            sys.exit ("evince-smooth-scroll: %s matched %d times (expected 1); "
                      "the source does not look like evince 48.x - refusing to patch"
                      % (what, n))
        return haystack.index (needle)

    entry = ("static gboolean\n"
             "ev_view_scroll_event (GtkWidget *widget, GdkEventScroll *event)\n"
             "{")
    pos = unique (src, entry, "ev_view_scroll_event() definition")
    src = src[:pos] + helpers + "\n\n" + src[pos:]

    tail = ("\t\tstate &= ~GDK_SHIFT_MASK;\n"
            "\t}\n"
            "\n"
            "\tfit_width = ev_view_page_fits (view, GTK_ORIENTATION_HORIZONTAL);")
    pos = unique (src, tail, "end of the Shift+wheel block")
    src = (src[:pos]
           + "\t\tstate &= ~GDK_SHIFT_MASK;\n\t}\n\n"
           + hook + "\n\n"
           + "\tfit_width = ev_view_page_fits (view, GTK_ORIENTATION_HORIZONTAL);"
           + src[pos + len (tail):])

    if src.count ("ev_view_smooth_scroll_by") != 2:
        sys.exit ("evince-smooth-scroll: internal error, insertion failed")

    with open (src_path, "w", encoding="utf-8") as f:
        f.write (src)

    print ("evince-smooth-scroll: animated scrolling added to libview/ev-view.c")
  '';
in
{
  evince = prev.evince.overrideAttrs (old: {
    nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ prev.python3 ];

    postPatch = (old.postPatch or "") + ''
      python3 ${patcher} libview/ev-view.c ${helpers} ${hook}
    '';
  });
}

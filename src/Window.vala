namespace TextPieces {

    [GtkTemplate (ui = "/com/github/liferooter/textpieces/ui/Window.ui")]
    public class Window : Adw.ApplicationWindow {

        private const ActionEntry[] ACTION_ENTRIES = {
            { "apply", action_apply },
            { "preferences", action_preferences },
            { "about", action_about },
            { "copy", action_copy }
        };

        public Window (Gtk.Application app) {
            Object (application: app);
        }

        construct {
            add_action_entries (ACTION_ENTRIES, this);
        }

        void action_apply () {
            // Not Implemented Yet
            message ("ACTION APPLY");
        }

        void action_preferences () {
            // Not Implemented Yet
            message ("ACTION PREFERENCES");
        }

        void action_about () {
            // Not Implemented Yet
            message ("ACTION ABOUT");
        }

        void action_copy () {
            // Not Implemented Yet
            message ("ACTION COPY");
        }
    }
}

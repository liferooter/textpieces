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
            // Load actions
            add_action_entries (ACTION_ENTRIES, this);

            // Set help overlay
            var builder = new Gtk.Builder.from_resource ("/com/github/liferooter/textpieces/ui/ShortcutsWindow.ui");
            var overlay = (Gtk.ShortcutsWindow) builder.get_object ("overlay");
            set_help_overlay (overlay);
        }

        void action_apply () {
            // Not Implemented Yet
            message ("ACTION APPLY");
        }

        void action_preferences () {
            var prefs = new Preferences () {
                transient_for =  this
            };
            prefs.present ();
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

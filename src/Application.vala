namespace TextPieces {

    struct ActionAccel {
        string action;
        string accel;
    }

    class Application : Gtk.Application {
        public static GLib.Settings settings;

        private const ActionAccel[] ACTION_ACCELS = {
            { "win.apply", "<Alt>Return" },
            { "win.preferences", "<Control>comma" },
            { "win.copy", "<Control><Shift>c" },
            { "window.close", "<Control>q"},
        };

        public Application () {
            Object (
                flags: ApplicationFlags.NON_UNIQUE,
                application_id: "com.github.liferooter.textpieces"
            );
        }

        static construct {
            settings = new GLib.Settings ("com.github.liferooter.textpieces");
        }

        protected override void activate () {
            // Initialize libs
            Adw.init ();
            Gtk.Sourceinit ();

            // Bind dark theme to the settings
            settings.bind ("dark-theme", ((!) Gtk.Settings.get_default ()),
                           "gtk-application-prefer-dark-theme", GLib.SettingsBindFlags.DEFAULT);

            // Load custom CSS
            var css_provider = new Gtk.CssProvider ();
            css_provider.load_from_resource ("/com/github/liferooter/textpieces/style.css");
            Gtk.StyleContext.add_provider_for_display (
                (!) Gdk.Display.get_default (),
                css_provider,
                Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
            );

            foreach (var action_accel in ACTION_ACCELS) {
                set_accels_for_action (action_accel.action, { action_accel.accel });
            }

            // Create window
            var win = get_active_window () ?? new TextPieces.Window (this);
            win.present ();
        }

        public static int main (string[] args) {
            var app = new TextPieces.Application ();
            return app.run (args);
        }
    }
}

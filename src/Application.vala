namespace Textpieces {
    class Application : Gtk.Application {
        public static MainWindow win = null;
        public static GLib.Settings settings;

        public Application () {
            Object (
                flags: ApplicationFlags.FLAGS_NONE,
                application_id: "com.github.liferooter.textpieces"
            );
        }

        static construct {
            settings = new GLib.Settings ("com.github.liferooter.textpieces");
        }

        protected override void activate () {
            // Initialize Libhandy
            Hdy.init ();

            // Load custom CSS
            var css_provider = new Gtk.CssProvider ();
            css_provider.load_from_resource ("/com/github/liferooter/textpieces/css/main.css");
            Gtk.StyleContext.add_provider_for_screen (
                Gdk.Screen.get_default (),
                css_provider,
                Gtk.STYLE_PROVIDER_PRIORITY_USER
            );

            // Create window
            if (win == null) {
                win = new MainWindow (this);
            }
            win.present ();
        }

        public static int main (string[] args) {
            // Ensure types from templates
            typeof (Textpieces.ToolEntry).ensure ();

            var app = new Textpieces.Application ();
            return app.run (args);
        }
    }
}

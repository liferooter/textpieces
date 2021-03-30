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

namespace Textpieces {
    class Application : Gtk.Application {
        public static GLib.Settings settings;

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
            Gtk.Source_init ();

            // Load custom CSS
            var css_provider = new Gtk.CssProvider ();
            css_provider.load_from_resource ("/com/github/liferooter/textpieces/style.css");
            Gtk.StyleContext.add_provider_for_display (
                (!) Gdk.Display.get_default (),
                css_provider,
                Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
            );

            // Create window
            var win = get_active_window ()
            (win ?? new TextPieces.Window (this)).present ();
        }

        public static int main (string[] args) {
            // Ensure types from templates
            typeof (Textpieces.ToolEntry).ensure ();

            var app = new Textpieces.Application ();
            return app.run (args);
        }
    }
}

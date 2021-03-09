/* application.vala
 *
 * Copyright 2021 Liferooter <glebsmirnov0708@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

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
            Hdy.init();

            // Load custom CSS
            var css_provider = new Gtk.CssProvider ();
	        css_provider.load_from_resource ("com/github/liferooter/textpieces/style.css");
	        Gtk.StyleContext.add_provider_for_screen (
	            Gdk.Screen.get_default (),
	            css_provider,
	            Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
            );

            // Create window
            if (win == null) {
                win = new MainWindow (this);
            }
            win.present ();
        }

        public static int main (string[] args) {
            var app = new Textpieces.Application ();
            return app.run (args);
        }
    }
}

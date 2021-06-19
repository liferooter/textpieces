/* Application.vala
 *
 * Copyright 2021 Gleb Smirnov <glebsmirnov0708@gmail.com>
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


namespace TextPieces {

    struct ActionAccel {
        string action;
        string accel;
    }

    class Application : Gtk.Application {
        public static GLib.Settings settings;

        private const ActionAccel[] ACTION_ACCELS = {
            { "win.apply", "<Alt>Return" },
            { "win.copy", "<Control><Shift>c" },
            { "win.preferences", "<Control>comma" },
            { "win.show-help-overlay", "<Control>question" },
            { "win.stop-search", "<Alt>Left/Escape" },
            { "window.close", "<Control>q"}
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
                set_accels_for_action (action_accel.action, action_accel.accel.split ("/"));
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

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

    class Application : Adw.Application {
        public static GLib.Settings settings;

        public ToolsController tools;

        private const ActionAccel[] ACTION_ACCELS = {
            { "win.escape", "Escape" },
            { "win.apply", "<Alt>a" },
            { "win.copy", "<Alt>c" },
            { "win.preferences", "<Control>comma" },
            { "win.show-help-overlay", "<Control>question" },
            { "win.load-file", "<Control>o" },
            { "win.save-as", "<Control>s" },
            { "win.toggle-search", "<Alt>s" },
            { "win.jump-to-args", "<Alt>Return" },
            { "window.close", "<Control>q / <Control>w" },
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
            tools = new ToolsController ();

            // Initialize libs
            Gtk.Sourceinit ();

            // Use dark theme
            Gtk.Settings.get_default ().gtk_application_prefer_dark_theme = true;

            foreach (var action_accel in ACTION_ACCELS) {
                set_accels_for_action (
                    action_accel.action,
                    action_accel.accel.split (" / ")
                );
            }

            // Create window
            var win = new TextPieces.Window () {
                application = this
            };
            win.present ();
        }

        public static int main (string[] args) {
            var app = new TextPieces.Application ();
            return app.run (args);
        }
    }
}

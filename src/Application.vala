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

    /**
     * Action accelerator
     */
    struct ActionAccel {
        string action;
        string accel;
    }

    /**
     * Text Pieces application
     */
    class Application : Adw.Application {
        /**
         * Text Pieces settings
         */
        public static GLib.Settings settings;

        /**
         * Tools controller
         */
        public static ToolsController tools;

        /**
         * Application actions
         *
         * Every entry has this form:
         * {{{
         *   { "application-name", action_callback }
         * }}}
         */
        private static ActionEntry[] ACTIONS = {
            { "quit", quit }
        };

        /**
         * Shortcuts for actions
         *
         * Every entry has this form:
         * {{{
         *   { "prefix.action", "shortcut" }
         * }}}
         */
        private static ActionAccel[] ACTION_ACCELS = {
            /* Window actions */
            { "win.apply"            , "<Control>Return" },
            { "win.copy"             , "<Control><Shift>c" },
            { "win.open-preferences" , "<Control>comma" },
            { "win.show-help-overlay", "<Control>question" },
            { "win.load-file"        , "<Control>o" },
            { "win.save-as"          , "<Control>s" },
            { "win.toggle-search"    , "<Alt>s" },
            { "win.jump-to-args"     , "<Control>e" },
            { "window.close"         , "<Control>w" },

            /* Application actions */
            { "app.quit"             , "<Control>q" }
        };

        static construct {
            /* Load settingse */
            settings = new GLib.Settings ("com.github.liferooter.textpieces");

            /* Load tools */
            tools = new ToolsController ();
        }

        public Application () {
            Object (
                flags: ApplicationFlags.FLAGS_NONE,
                application_id: "com.github.liferooter.textpieces"
            );
        }

        /**
         * Startup method
         *
         * This method is called once at application
         * startup. Do here everything that have to be
         * done only once. Think of it as another `main`.
         */
        protected override void startup () {
            base.startup ();

            /* Initialize libs */
            Gtk.Sourceinit ();

            /* Initialize localization */
            Intl.bindtextdomain (Config.GETTEXT_PACKAGE, Config.GNOMELOCALEDIR);
            Intl.bind_textdomain_codeset (Config.GETTEXT_PACKAGE, "UTF-8");

            /* Initialize libs */
            Gtk.Sourceinit ();

            /* Setup color scheme */
            settings.changed.connect ((key) => {
                if (key == "color-scheme")
                    color_scheme_changed_cb ();
            });
            color_scheme_changed_cb ();

            /* Setup actions */
            add_action_entries (ACTIONS, this);

            /* Setup accels */
            foreach (var action_accel in ACTION_ACCELS) {
                set_accels_for_action (
                    action_accel.action,
                    { action_accel.accel }
                );
            }
        }

        /**
         * Activate method
         *
         * This method is called every time
         * when application is activated.
         * Depending on system it may be done
         * once or many times. Think of it as
         * an application entry point.
         */
        protected override void activate () {
            /* Get active window */
            var win = get_active_window ();
            if (win == null)
                /* Create window if it doesn't exist */
                win = new TextPieces.Window (this);

            /* Present it to user */
            win.present ();
        }

        /**
         * Update color scheme from settings
         */
        void color_scheme_changed_cb () {
            switch (settings.get_string ("color-scheme")) {
            case "dark":
                style_manager.color_scheme = FORCE_DARK;
                break;
            case "light":
                style_manager.color_scheme = FORCE_LIGHT;
                break;
            case "system-default":
                style_manager.color_scheme = PREFER_LIGHT;
                break;
            }
        }

        /**
         * Program entry point
         *
         * Do nothing here except creating
         * application instance. For everything
         * else use `Application::startup` and
         * `Application::activate`.
         */
        public static int main (string[] args) {
            var app = new TextPieces.Application ();
            return app.run (args);
        }
    }
}

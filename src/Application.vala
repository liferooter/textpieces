// Copyright 2021 Gleb Smirnov <glebsmirnov0708@gmail.com>
// SPDX-FileCopyrightText: 2021 Gleb Smirnov <glebsmirnov0708@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

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
         * Application instance
         */
        public static TextPieces.Application instance;

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
            { "quit", quit },
            { "new-window", new_window }
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
            /*              Window actions              */
            { "win.apply"             , "<Ctrl>Return"   },
            { "win.copy"              , "<Ctrl><Shift>c" },
            { "win.open-preferences"  , "<Ctrl>comma"    },
            { "win.show-help-overlay" , "<Ctrl>question" },
            { "win.load-file"         , "<Ctrl>o"        },
            { "win.save-as"           , "<Ctrl>s"        },
            { "win.toggle-search"     , "<Alt>s"         },
            { "win.jump-to-args"      , "<Ctrl>e"        },
            { "win.show-search"       , "<Ctrl>f"        },
            { "window.close"          , "<Ctrl>w"        },

            /*            Application actions           */
            { "app.quit"              , "<Ctrl>q"        },
            { "app.new-window"        , "<Ctrl>n"        }
        };

        static construct {
            /* Load settingse */
            settings = new GLib.Settings ("com.github.liferooter.textpieces");

            /* Load tools */
            tools = new ToolsController ();
        }

        /**
         * CSS provider used to set style scheme
         */
        private Gtk.CssProvider style_scheme_css_provider = new Gtk.CssProvider ();

         /**
          * Style scheme
          */
        public GtkSource.StyleScheme style_scheme {
            set {
                _style_scheme = value;

                /* Apply style scheme to the application */
                var is_dark = Recoloring.is_scheme_dark (value);
                Adw.StyleManager.get_default ()
                    .color_scheme = is_dark
                        ? Adw.ColorScheme.FORCE_DARK
                        : Adw.ColorScheme.FORCE_LIGHT;
                style_scheme_css_provider.load_from_data (
                    Recoloring.generate_css (value).data
                );

                settings.set_string ("style-scheme", value.id);
            } get {
                return _style_scheme;
            }
        }
        private GtkSource.StyleScheme _style_scheme = GtkSource.StyleSchemeManager
            .get_default ()
            .get_scheme (settings.get_string ("style-scheme"));

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

            /* Place an instance to static field
               to bring it into global scope */
            instance = this;

            /* Initialize localization */
            Intl.bindtextdomain (Config.GETTEXT_PACKAGE, Config.GNOMELOCALEDIR);
            Intl.bind_textdomain_codeset (Config.GETTEXT_PACKAGE, "UTF-8");

            /* Setup style scheme */
            Gtk.StyleContext.add_provider_for_display (
                Gdk.Display.get_default (),
                style_scheme_css_provider,
                Gtk.STYLE_PROVIDER_PRIORITY_USER
            );

            /* Initialize libs */
            GtkSource.init ();

            /* Initialize recoloring mechanism */
            style_scheme = style_scheme;

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
            /* Create window window */
            new_window ();
        }

        /**
         * Shutdown method
         *
         * This method is called when app
         * is being terminated.
         */
        protected override void shutdown () {
            /* Save window geometry if can */
            var win = (TextPieces.Window?) get_active_window ();
            win?.save_window_size ();

            base.shutdown ();
        }

        /**
         * New window action
         */
        public void new_window () {
            var win = new TextPieces.Window (this);

            win.present ();
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

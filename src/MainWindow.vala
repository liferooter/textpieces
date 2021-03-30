namespace Textpieces {
    [GtkTemplate (ui = "/com/github/liferooter/textpieces/ui/window.ui")]
    public class MainWindow : Hdy.ApplicationWindow {
        [GtkChild]
        public unowned Gtk.SourceBuffer text_buffer;
        [GtkChild]
        private unowned Gtk.SourceView text_view;
        [GtkChild]
        private unowned Gtk.Popover copied_popover;
        [GtkChild]
        private unowned Gtk.Box args_box;

        Tool? current_tool = null;

        public const string ACTION_UNDO = "undo";
        public const string ACTION_REDO = "redo";
        public const string ACTION_APPLY = "apply";
        public const string ACTION_SHORTCUTS = "show-keybindings";
        public const string ACTION_PREFERENCES = "show-preferences";
        public const string ACTION_ABOUT = "about";
        public const string ACTION_COPY = "copy";

        private const ActionEntry[] ACTION_ENTRIES = {
            { ACTION_UNDO, action_undo },
            { ACTION_REDO, action_redo },
            { ACTION_APPLY, action_apply },
            { ACTION_SHORTCUTS, action_shortcuts },
            { ACTION_PREFERENCES, action_preferences },
            { ACTION_ABOUT, action_about },
            { ACTION_COPY, action_copy }
        };

        public SimpleActionGroup actions;

        public MainWindow (Gtk.Application app) {
            Object (application: app);
        }

        construct {

            // Update settings
            Textpieces.Application.settings.changed.connect (update_from_settings);
            update_from_settings ();


            // Setup keybindings
            var keybindings = new Gtk.AccelGroup ();

            // Show shortcuts window (Ctrl+?)
            keybindings.connect (
                Gdk.Key.question,
                Gdk.ModifierType.CONTROL_MASK,
                0,
                () => {
                    action_shortcuts ();
                    return true;
                }
            );

            // Show preferences window (Ctrl+,)
            keybindings.connect (
                Gdk.keyval_from_name ("comma"),
                Gdk.ModifierType.CONTROL_MASK,
                0,
                () => {
                    action_preferences ();
                    return true;
                }
            );

            this.add_accel_group (keybindings);

            // Setup actions
            actions = new SimpleActionGroup ();
            actions.add_action_entries (ACTION_ENTRIES, this);
            insert_action_group ("win", actions);

            check_whether_can_do_actions ();
        }

        [GtkCallback]
        void on_select_tool (Tool tool) {
            current_tool = tool;
            
            check_whether_can_do_actions ();
            
            // Ask for the arguments
            args_box.foreach ((el) => {
                el.destroy ();
            });

            foreach (var arg in current_tool.args) {
                var argument = new Argument (arg);
                args_box.add (argument);
            }

            args_box.visible = current_tool.args.length > 0;
        }

        void update_from_settings () {
            var settings = Textpieces.Application.settings;

            // Setup SourceView
            text_view.show_line_numbers = settings.get_boolean ("show-line-numbers");
            text_view.background_pattern = settings.get_boolean ("show-grid")
                ? Gtk.SourceBackgroundPatternType.GRID
                : Gtk.SourceBackgroundPatternType.NONE;
            text_view.tab_width = settings.get_uint ("tab-width");
            text_view.indent_width = (int) settings.get_uint ("tab-width");
            text_view.insert_spaces_instead_of_tabs = settings.get_boolean ("tab-to-spaces");

            Gtk.Settings.get_default ().gtk_application_prefer_dark_theme
                = settings.get_boolean("prefer-dark");

        }

        [GtkCallback]
        void check_whether_can_do_actions () {
            actions.lookup_action (ACTION_APPLY).set ("enabled", (text_buffer.text != "" && current_tool != null));
            Idle.add (() => {
                actions.lookup_action (ACTION_UNDO).set ("enabled", text_buffer.can_undo);
                actions.lookup_action (ACTION_REDO).set ("enabled", text_buffer.can_redo);
                return Source.REMOVE;
            });
        }

        void action_undo () {
            if (text_buffer.can_undo)
                text_buffer.undo ();
        }

        void action_redo () {
            if (text_buffer.can_redo)
                text_buffer.redo ();
        }
        void action_apply () {
            var arg_entries = args_box.get_children ();
            var args = new string[arg_entries.length ()];
            for (var i = 0; i < arg_entries.length (); i++) {
                args[i] = ((Argument) arg_entries.nth_data(i)).arg_entry.get_text ();
            }

            Result result;
            if (text_buffer.has_selection) {
                Gtk.TextIter start, end;
                text_buffer.get_selection_bounds (out start, out end);

                result = current_tool.func (text_buffer.get_text (start, end, false), args);
                if (result.type == ResultType.OK) {
                    text_buffer.begin_user_action ();
                    text_buffer.@delete (ref start, ref end);
                    text_buffer.insert (ref start, result.value, -1);
                    text_buffer.end_user_action ();
                }
            }
            else {
                result = current_tool.func (text_buffer.text, args);
                if (result.type == ResultType.OK) {
                    text_buffer.begin_user_action ();
                    text_buffer.text = result.value;
                    text_buffer.end_user_action ();
                }
            }

            if (result.type == ResultType.ERROR) {
                var error_message = new ErrorDialog (result.value, this);
                error_message.show_all ();
                error_message.present ();
            }
        }
        void action_shortcuts () {
            var shortcuts_window = new Textpieces.ShortcutsWindow (this);
            shortcuts_window.show_all ();
            shortcuts_window.present ();
        }
        void action_preferences () {
            var prefs = new Textpieces.Preferences (this);

            prefs.show_all ();
            prefs.present ();
        }

        void action_about () {
            var about = new Textpieces.AboutDialog (this);

            about.show_all ();
            about.present ();
        }

        void action_copy () {
            var clipboard = Gtk.Clipboard.get_default (Gdk.Display.get_default ());
            clipboard.set_text (text_buffer.text, -1);

            copied_popover.popup ();
        }
    }
}

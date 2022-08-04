// SPDX-FileCopyrightText: 2022 Gleb Smirnov <glebsmirnov0708@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

namespace TextPieces {
    /**
     * Message toast timeout, in seconds
     */
    const uint TOAST_TIMEOUT = 2;

    /**
     * Text Pieces' editor widget
     */
    [GtkTemplate (ui = "/com/github/liferooter/textpieces/ui/Editor.ui")]
    class Editor : Adw.Bin {
        [GtkChild] unowned GtkSource.View editor;
        [GtkChild] unowned Gtk.Box arguments_box;
        [GtkChild] unowned Adw.ToastOverlay message_overlay;

        /**
         * Whether to wrap lines
         */
        public bool wrap_lines {
            set {
                editor.wrap_mode = value
                    ? Gtk.WrapMode.WORD_CHAR
                    : Gtk.WrapMode.NONE;
            } get {
                return editor.wrap_mode == WORD_CHAR;
            }
        }

        /**
         * CSS provider used to set editor font
         */
        Gtk.CssProvider editor_font_css_provider = new Gtk.CssProvider ();

        /**
         * Editor font
        */
        public string? editor_font {
            set {
                if (value != null) {
                    editor_font_css_provider.load_from_data ("""
                        .monospace {
                            font-family: %s;
                        }
                    """.printf (value).data);
                } else {
                    editor_font_css_provider.load_from_data ({});
                }
            }
        }

        /**
         * Style scheme binding
         */
        private Binding style_scheme_binding;

        /**
         * Editor's application
         *
         * Used to bind editor style scheme
         * to global style scheme.
         */
        public TextPieces.Application application {
            get {
                return Application.instance;
            }
        }

        ~Editor () {
            /* Disconnect global style scheme */
            style_scheme_binding.unbind ();
        }

        construct {
            /* Bind some values to settings */
            with (Application.settings) {
                bind ("tabs-to-spaces", editor, "insert-spaces-instead-of-tabs", GET);
                bind ("spaces-in-tab",  editor, "tab-width",                     GET);
                bind ("font-name",      this,   "editor-font",                   GET);
                bind ("wrap-lines",     this,   "wrap-lines",                    GET);
            }

            /* Add style provider with editor font */
            get_style_context ().add_provider (
                editor_font_css_provider,
                Gtk.STYLE_PROVIDER_PRIORITY_USER
            );

            /* Bind editor style scheme
               to application style scheme */
            application.bind_property (
                "style-scheme",
                editor.buffer,
                "style-scheme",
                SYNC_CREATE
            );
        }

        /**
         * Get selection or whole text if there are no selection
         */
        public string get_selection () {
            var buffer = editor.buffer;

            Gtk.TextIter start, end;

            if (buffer.has_selection) {
                buffer.get_selection_bounds (out start, out end);
            } else {
                buffer.get_bounds (out start, out end);
            }

            return buffer.get_text (start, end, false);
        }

        /**
         * Copy text from editor
         */
        public void copy_text () {
            Gdk.Display
                .get_default ()
                .get_clipboard ()
                .set_text (editor.buffer.text);
            show_message (_("Text is copied"));
        }

        /**
         * Replace selection or whole text if there are no selection
         */
        public void replace_selection (string text) {
            var buffer = editor.buffer;

            Gtk.TextIter start, end;

            var has_selection = buffer.has_selection;

            if (has_selection) {
                buffer.get_selection_bounds (out start, out end);
            } else {
                buffer.get_bounds (out start, out end);
            }

            var start_offset = start.get_offset();

            buffer.begin_user_action ();

            /* Replace selection by given text */
            buffer.delete (ref start, ref end);
            buffer.insert (ref start, text, -1);

            buffer.end_user_action ();

            if (has_selection) {
                buffer.get_iter_at_offset (
                    out start,
                    start_offset
                );
                buffer.get_iter_at_offset (
                    out end,
                    start_offset + text.length
                );

                buffer.select_range (start, end);
            } else {
                /* TODO: Invent better behavior of cursor
                         after whole-text transformations */
                buffer.place_cursor (start);
            }
        }

        /**
         * Set argument list
         */
        public void set_arguments (string[] arguments) {
            var children = arguments_box.observe_children ();
            for (int i = (int) children.get_n_items () - 1; i >= 0; i--) {
                ((Gtk.Entry) children.get_item (i)).destroy ();
            }

            foreach (var argument in arguments) {
                var entry = new Gtk.Entry () {
                    placeholder_text = argument,
                    css_classes = {"monospace"}
                };

                entry.activate.connect (() => {
                    move_focus (TAB_FORWARD);
                });
                arguments_box.append (entry);
            }

            arguments_box.visible = arguments.length != 0;
        }

        /**
         * Get argument values
         */
        public string[] get_arguments () {
            var args = new string[0];

            var children = arguments_box.observe_children ();
            for (var i = 0; i < children.get_n_items (); i++) {
                args += ((Gtk.Entry) children.get_item (i)).text;
            }

            return args;
        }

        /**
         * Move focus to the first argument entry
         */
        public void jump_to_args () {
            if (arguments_box.visible)
                ((Gtk.Widget) arguments_box.observe_children ().get_item (0))
                    .grab_focus ();
        }

        /**
         * Save text to file
         */
        public void save_as (File file) throws FileError {
            /* Try to save text to file */
            FileUtils.set_contents (
                file.get_path (),
                editor.buffer.text
            );
        }

        /**
         * Load text from file
         */
        public void load_from (File file) throws FileError {
            /* Try to load text from file */
            string text;

            FileUtils.get_contents (
                file.get_path (),
                out text
            );

            editor.buffer.text = text;
        }

        /**
         * Show message in a toast
         */
        public void show_message (string message) {
            message_overlay.add_toast (new Adw.Toast (message) {
                priority = HIGH,
                timeout = TOAST_TIMEOUT
            });
        }

        /**
         * Update editor's top margin
         */
        public bool update_editor_margin () {
            /* Calculate new margin */
            Graphene.Rect bounds;
            assert (arguments_box.compute_bounds (this, out bounds));

            var old_margin = editor.top_margin;
            var new_margin = arguments_box.visible
                ? (int) Math.ceil (bounds.get_height ())
                : 6;

            /* Set margin */
            editor.top_margin = new_margin;

            /* Restore scroll position */
            editor.vadjustment.value = double.max(editor.vadjustment.value - old_margin + new_margin, 0);

            return Source.REMOVE;
        }
    }
}

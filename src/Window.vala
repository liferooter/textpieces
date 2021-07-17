/* Window.vala
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

    const uint NOTIFICATION_HIDE_TIMEOUT = 2000;

    [GtkTemplate (ui = "/com/github/liferooter/textpieces/ui/Window.ui")]
    public class Window : Adw.ApplicationWindow {

        [GtkChild]
        unowned Gtk.ListBox search_listbox;
        [GtkChild]
        unowned Gtk.SearchEntry search_entry;
        [GtkChild]
        unowned Gtk.Stack search_stack;
        [GtkChild]
        unowned Gtk.Revealer notification_revealer;
        [GtkChild]
        unowned Gtk.Label notification_label;
        [GtkChild]
        unowned Gtk.Image tool_icon;
        [GtkChild]
        unowned Gtk.Label tool_label;
        [GtkChild]
        unowned Gtk.ToggleButton tool_button;
        [GtkChild]
        unowned Gtk.SourceView editor;
        [GtkChild]
        unowned Gtk.Viewport search_viewport;

        Gtk.FilterListModel search_list;

        uint? notification_hide_source = null;

        Tool selected_tool = null;

        private const ActionEntry[] ACTION_ENTRIES = {
            { "apply", action_apply },
            { "preferences", action_preferences },
            { "about", action_about },
            { "copy", action_copy },
            { "hide-notification", hide_notification },
            { "toggle-search", toggle_search }
        };

        construct {
            // Load actions
            add_action_entries (ACTION_ENTRIES, this);

            ((SimpleAction) lookup_action ("apply")).set_enabled (false);

            tool_button.notify["active"].connect(() => {
                if (!tool_button.active)
                    editor.grab_focus ();
                else
                    search_viewport.vadjustment.set_value (0);
            });
        }

        public void setup_tools () {
            search_list = new Gtk.FilterListModel (
                ((TextPieces.Application) application).tools.all_tools,
                new Gtk.CustomFilter (
                    tool_filter_func
                )
            );

            search_listbox.bind_model (
                search_list,
                build_list_row
            );
        }

        void action_apply () {
            if (selected_tool == null)
                return;

            var buffer = editor.buffer;
            var has_selection = buffer.has_selection;

            Gtk.TextIter start, end;

            if (has_selection)
                buffer.get_selection_bounds (out start, out end);
            else
                buffer.get_bounds (out start, out end);

            var start_offset = start.get_offset ();

            var result = selected_tool.apply (
                buffer.get_text (start, end, false)
            );

            string result_text;
            if (result.successful) {
                result_text = result.output;
            } else {
                send_notification (result.output);
                return;
            }
            var result_text_len = result_text.char_count ();

            buffer.begin_user_action ();

            buffer.@delete (ref start, ref end);
            buffer.insert (ref start, result_text, result_text_len);

            buffer.end_user_action ();

            if (has_selection) {
                buffer.get_iter_at_offset (
                    out start,
                    start_offset
                );
                buffer.get_iter_at_offset (
                    out end,
                    start_offset + result_text_len
                );
                buffer.select_range (start, end);
            } else {
                buffer.get_start_iter (out start);
                buffer.place_cursor (start);
            }
        }

        void action_preferences () {
            var prefs = new Preferences () {
                transient_for =  this,
                application = application
            };
            prefs.setup_tools ();
            prefs.present ();
        }

        void action_about () {
            string[] AUTHORS = {"Gleb Smirnov <glebsmirnov0708@gmail.com>"};
		    string[] ARTISTS = {"Tobias Bernard https://tobiasbernard.com"};

		    Gtk.show_about_dialog (
		        this,
		        "program-name", _("Text Pieces"),
		        "logo-icon-name", "com.github.liferooter.textpieces",
		        "comments", _("Swiss knife of text processing"),
		        "version", Config.VERSION,
		        "license-type", Gtk.License.GPL_3_0,
		        "website", "https://gitlab.com/liferooter/textpieces",
		        "artists", ARTISTS,
		        "authors", AUTHORS,
		        null
		    );
        }

        void action_copy () {
            Gdk.Display.get_default ()
                       .get_clipboard ()
                       .set_text (editor.buffer.text);
            send_notification (_("Text is copied to clipboard"));
        }

        void hide_notification () {
            clear_notification_hide_timeout ();
            notification_revealer.set_reveal_child (false);
        }

        public bool tool_filter_func (Object item) {
            var tool = (Tool) item;

            var name = tool.name.casefold ();
            var description = tool.description.casefold ();
            var terms = search_entry.text.casefold ().split (" ");

            var min_name = 0;
            var min_desc = 0;
            int match;

            foreach (var term in terms) {
                if ((match = description.index_of (term, min_desc)) != -1)
                    min_desc = match + term.length;
                else if ((match = name.index_of (term, min_name)) != -1)
                    min_name = match + term.length;
                else
                    return false;
            }

            return true;
        }

        void send_notification (string text) {
            clear_notification_hide_timeout ();
            notification_label.set_label (text);
            notification_revealer.set_reveal_child (true);
            notification_hide_source = Timeout.add (
                NOTIFICATION_HIDE_TIMEOUT,
                () => {
                    hide_notification ();
                    return Source.REMOVE;
                }
            );
        }

        [GtkCallback]
        string get_page_name (bool search_enabled) {
            if (search_enabled) {
                return "search";
            } else {
                return "editor";
            }
        }

        [GtkCallback]
        void on_search_changed () {
            search_list.filter.changed (Gtk.FilterChange.DIFFERENT);
            search_stack.set_visible_child_name (
                search_list.get_n_items () == 0
                    ? "placeholder"
                    : "search"
            );
        }

        [GtkCallback]
        bool on_search_entry_key (uint keyval,
                                  uint keycode,
                                  Gdk.ModifierType state) {
            if (keyval == Gdk.Key.Down) {
                var first_row = search_listbox.get_row_at_index (0);
                if (first_row != null) {
                    first_row.grab_focus ();
                    return true;
                }
            }
            return false;
        }

        [GtkCallback]
        bool on_search_listbox_key (uint keyval,
                                    uint keycode,
                                    Gdk.ModifierType state) {
            if (keyval == Gdk.Key.Up) {
                var focus = this.focus_widget;
                if (focus.get_type () == typeof (Adw.ActionRow) &&
                    ((Adw.ActionRow) focus).get_index () == 0)
                {
                    search_entry.grab_focus ();
                    return true;
                }
            }
            return false;
        }

        [GtkCallback]
        void on_row_activated (Gtk.ListBoxRow row) {
            var tool = (Tool) search_list.get_item (row.get_index ());

            selected_tool = tool;

            tool_icon.icon_name = tool.icon;
            tool_label.label = tool.name;
            search_entry.stop_search ();

            ((SimpleAction) lookup_action ("apply")).set_enabled (true);
        }

        void clear_notification_hide_timeout () {
            if (notification_hide_source != null) {
                Source.remove (notification_hide_source);
                notification_hide_source = null;
            }
        }

        void toggle_search () {
            tool_button.active = !tool_button.active;
        }
    }
}

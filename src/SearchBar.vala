// SPDX-FileCopyrightText: 2022 Gleb Smirnov <glebsmirnov0708@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

[GtkTemplate(ui = "/com/github/liferooter/textpieces/ui/SearchBar.ui")]
class TextPieces.SearchBar : Adw.Bin {
    [GtkChild] unowned SearchEntry      search_entry;
    [GtkChild] unowned Gtk.Entry        replace_entry;
    [GtkChild] unowned Gtk.Revealer     search_revealer;
    [GtkChild] unowned Gtk.ToggleButton search_replace;

    /**
     * Source view that this search bar is associated with
     */
    public GtkSource.View editor { get; set construct; }

    /**
     * Whether to parse query as regular expression
     */
    public bool use_regex { get; set; default = false; }

    /**
     * Whether the search is case sensitive.
     */
    public bool case_sensitive { get; set; default = false; }

    /**
     * Whether the search must match whole words only
     */
    public bool whole_words { get; set; default = false; }

    /**
     * Search settings
     */
    private GtkSource.SearchSettings search_settings = new GtkSource.SearchSettings () {
        wrap_around = true
    };

    /**
     * Search context
     */
    private GtkSource.SearchContext search_context;

    /**
     * Search cancelable
     */
    private Cancellable search_cancelable = new Cancellable ();

    /**
     * Get action entries
     */
    private ActionEntry[] action_entries () {
        return {
            { "hide"        , hide_search                    },
            { "show"        , show_search                    },
            { "show-replace", show_replace                   },
            { "next-match"  , () => { next_match.begin (); } },
            { "prev-match"  , () => { prev_match.begin (); } },
            { "replace"     , replace                        },
            { "replace-all" , replace_all                    },
        };
    }

    construct {
        search_context = new GtkSource.SearchContext (
            (GtkSource.Buffer) editor.buffer,
            search_settings
        );

        /* Bind properties */
        search_entry.bind_property (
            "query",
            search_settings,
            "search-text"
        );

        search_revealer.bind_property (
            "child-revealed",
            search_context,
            "highlight"
        );

        this.bind_property (
            "use-regex",
            search_settings,
            "regex-enabled"
        );

        this.bind_property (
            "case-sensitive",
            search_settings,
            "case-sensitive"
        );

        this.bind_property (
            "whole-words",
            search_settings,
            "at-word-boundaries"
        );

        /* Setup search entry */
        search_entry.set_context (search_context);

        /* Setup action entries */
        var action_group = new SimpleActionGroup ();
        action_group.add_action_entries (action_entries (), this);
        insert_action_group ("search", action_group);
    }

    /**
     * Show search
     */
    public void show_search () {
        search_entry.query = "";
        search_revealer.reveal_child = true;
        search_cancelable.reset ();
        search_entry.grab_focus ();
    }

    /**
     * Show search in replace mode
     */
    public void show_replace () {
        show_search ();
        search_replace.active = true;
    }

    /**
     * Hide search
     */
    private void hide_search () {
        search_revealer.reveal_child = false;
        search_replace.active = false;
        search_cancelable.cancel ();
    }

    /**
     * Move to next match
     */
    public async void next_match () {
        var buffer = editor.buffer;
        Gtk.TextIter begin, end;

        buffer.get_selection_bounds (out begin, out end);
        begin.order (ref end);
        var cursor = end.copy ();

        try {
            bool has_wrapped;

            var found = yield search_context.forward_async (
                cursor,
                search_cancelable,
                out begin,
                out end,
                out has_wrapped
            );

            if (!found) {
                return;
            }

            buffer.select_range (begin, end);
        } catch (Error e) {
            critical ("failed to move to next search match: %s", e.message);
        }

        editor.scroll_mark_onscreen (buffer.get_insert ());
    }

    /**
     * Move to previous match
     */
    public async void prev_match () {
        var buffer = editor.buffer;
        Gtk.TextIter begin, end;

        buffer.get_selection_bounds (out begin, out end);
        begin.order (ref end);
        var cursor = begin.copy ();

        try {
            bool has_wrapped;

            var found = yield search_context.backward_async (
                cursor,
                search_cancelable,
                out begin,
                out end,
                out has_wrapped
            );

            if (!found) {
                return;
            }

            buffer.select_range (begin, end);
        } catch (Error e) {
            critical ("failed to move to next search match: %s", e.message);
        }

        editor.scroll_mark_onscreen (buffer.get_insert ());
    }

    /**
     * Replace current occurrence
     */
    public void replace ()
        requires (search_entry.occurrence_position > 0)
    {
        var replacement = replace_entry.text;

        Gtk.TextIter start, end;
        editor.buffer.get_selection_bounds (out start, out end);

        try {
            search_context.replace (
                start,
                end,
                replacement,
                -1
            );
        } catch (Error e) {
            replace_entry.add_css_class ("error");
            replace_entry.error_bell ();
        }

        if (search_context.occurrences_count != 0)
            next_match.begin ();
    }

    /**
     * Replace all occurrences
     */
    public void replace_all () {
        var replacement = replace_entry.text;

        try {
            search_context.replace_all (
                replacement,
                -1
            );
        } catch (Error e) {
            replace_entry.add_css_class ("error");
            replace_entry.error_bell ();
        }
    }

    /**
     * Remove error style
     */
    [GtkCallback]
    void remove_error_style (Gtk.Widget widget) {
        widget.remove_css_class ("error");
    }

}

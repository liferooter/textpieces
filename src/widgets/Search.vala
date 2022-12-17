// SPDX-FileCopyrightText: 2022 Gleb Smirnov <glebsmirnov0708@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

using Gtk;
using Gdk;
using Adw;

[GtkTemplate(ui = "/com/github/liferooter/textpieces/ui/Search.ui")]
class TextPieces.Search : Bin {
    [GtkChild] unowned Viewport results_viewport;
    [GtkChild] unowned ListBox results_listbox;
    [GtkChild] unowned Stack search_stack;

    /**
     * Search entry to use
     */
    public Gtk.SearchEntry search_entry { get; construct; default = null; }

    /**
     * Tool list model
     */
    GLib.ListModel results_model;

    /**
     * Sorter for search results
     */
    Sorter sorter;

    /**
     * Filter for search results
     */
    Filter filter;

    /**
     * Search entry key event controller
     */
    EventControllerKey search_event_controller;

    construct {
        /* Create model for search results */
        sorter = new CustomSorter ((a, b) => tool_sort_func ((Tool) a, (Tool) b));
        filter = new CustomFilter (tool_filter_func);
        results_model = new SortListModel (
            new FilterListModel (
                Application.tools.all_tools,
                filter
            ),
            sorter
        );

        /* Bind model to list box */
        results_listbox.bind_model (
            results_model,
            build_list_row
        );

        /* Update search results on query changes */
        search_entry.changed.connect (update_search_results);

        /* Activate current row on activate */
        search_entry.activate.connect (activate_selected_result);

        /* Pass arrow keys events from
           search entry to list box */
        search_event_controller = new EventControllerKey ();
        search_event_controller.key_pressed.connect (on_search_entry_key);
        search_entry.add_controller (search_event_controller);
    }

    /**
     * Emitted when a tool is selected
     *
     * @param tool selected tool
     */
    public signal void tool_selected (Tool tool);

    /**
     * Reset search
     *
     * Clear the search entry, scroll to the top, reset selection
     */
    public void reset () {
        /* Clear the search entry */
        search_entry.text = "";
        /* Scroll to the top */
        results_viewport.vadjustment.value = 0;
        /* Select the first row */
        var row = results_listbox.get_row_at_index (0);
        results_listbox.select_row (row);
    }

    /**
     * Choose selected result
     */
    void activate_selected_result () {
        var row = results_listbox.get_selected_row ()
            ?? results_listbox.get_row_at_index (0);
        if (row != null)
            results_listbox.row_activated (row);
    }

    /**
     * Process key pressed in search entry
     *
     * Move focus to the first search result
     * if `Gdk.Key.Down` is pressed
     *
     * @param keyval    pressed key value
     * @param keycode   pressed key code
     * @param modifiers pressed modifiers
     *
     * @returnif whether the key press was handled
     */
    bool on_search_entry_key (uint keyval,
                              uint keycode,
                              ModifierType modifiers) {
        switch (keyval) {
            case (Key.Down):
            case (Key.Up):
                /* Move focus to listbox */
                results_listbox.get_selected_row()?.grab_focus ();
                /* Forward event to listbox */
                search_event_controller.forward (results_listbox);
                /* Grab focus back when done */
                search_entry.grab_focus ();

                return true;
            default:
                return false;
        }
    }

    /**
     * Emit `tool-selected` signal when tool is selected
     */
    [GtkCallback]
    void on_row_activated (ListBoxRow row) {
        var index = row.get_index ();
        var tool = (Tool) results_model.get_item (index);
        tool_selected (tool);
    }

    /**
     * Update list of search results
     */
    void update_search_results () {
        /* Invalidate search sorter and filter */
        sorter.changed (DIFFERENT);
        filter.changed (DIFFERENT);

        /* Select the first row if no row is selected */
        if (results_listbox.get_selected_row () == null) {
            results_listbox.select_row (
                results_listbox.get_row_at_index (0)
            );
        }

        /* Show placeholder if
           there are no tools found */
        search_stack.set_visible_child_name (
            results_model.get_n_items () == 0
                ? "placeholder"
                : "search"
        );
    }

    /**
     * Compare tools by search irrelevance
     *
     * Less relevant tool should be
     * larger than more relevant
     * to be below more relevant tool
     * in search results. If tools are
     * equal, compare tools' names.
     *
     * @param a one tool
     * @param b another tool
     *
     * @return zero if tools are equal, positive if `a` is larger, negative otherwise
     */
    public int tool_sort_func (Tool a, Tool b) {
        var query = search_entry.text;

        var res = calculate_irrelevance (a, query)
                - calculate_irrelevance (b, query);
        if (res == 0)
            return strcmp (a.translated_name, b.translated_name);
        return res;
    }

    /**
     * Functions used to filter tools by search relevance
     *
     * Don't show tool if its irrelevance is infinite
     *
     * @param tool  the tool
     * @param query search query
     *
     * @return whether to show tool in search results
     */
    public bool tool_filter_func (Object tool) {
        return calculate_irrelevance ((Tool) tool, search_entry.text) != int.MAX;
    }

    /**
     * Calculate tool irrelevance
     *
     * This method is used to filter
     * and sort search results
     *
     * @param tool  the tool
     * @param query search query
     *
     * @return tool's search irrelevance
     */
    static int calculate_irrelevance (Tool tool, string query) {
        /* Get case-independent form of search query */
        var casefolded_query = query.casefold ();

        return int.min (
            /* Calculate non-translated tool's irrelevance */
            calculate_irrelevance_for_fields ({
                tool.name       .casefold (),
                tool.description.casefold ()
            }, casefolded_query),
            /* Calculate translated tool's irrelevance */
            calculate_irrelevance_for_fields ({
                tool.translated_name       .casefold (),
                tool.translated_description.casefold ()
            }, casefolded_query)
        );
    }

    /**
     * Calculate fields' irrelevance
     *
     * This method gets list of fields
     * and search query and returns fields'
     * search irrelevance. The alghorythm is as follows:
     *
     * 1. If query is empty string, algorythm finishes,
     *    irrelevance is zero. It's used to fallback
     *    to alphabetical sort.
     * 2. At the start of the alghorythm irrelevance
     *    is equals to zero
     * 3. Query is divided into words, called terms
     * 4. Algorythm iterates over terms
     * 5. I search for term in fields, from the first
     *    field to the last field
     * 6. If term is not found, algorythm finishes,
     *    irrelevance is infinite
     * 7. If term is found in the field, increase
     *    irrelevance by the difference from the index of
     *    the match start and then cut out part of field
     *    from the start of field to the end of match
     * 8. At the end of the algorythm, increase
     *    irrelevance by sum of lengths of first fields
     *    which don't contain any terms
     *
     * @param fields list of the fields
     * @param query  search query
     *
     * @return tool's search irrelevance
     */
    static int calculate_irrelevance_for_fields (string[] fields, string query) {
        /* If query is empty, return zero */
        if (query == "")
            return 0;

        /* Split query to terms */
        var terms = query.split (" ");

        /* Create array of field begginings.
           It's used to easily cut fields as said
           in the algorythm */
        var field_beginning = new int[fields.length];

        /* Initial irrelevance is zero */
        var irrelevance = 0;

        /* Iterate over terms */
        foreach (var term in terms) {
            /* Find first field containing the term */
            var matching_field = 0;
            var match = 0;

            while (matching_field < fields.length
                   && (match = fields[matching_field].index_of (term, field_beginning[matching_field])) == -1) {
                matching_field++;
            }

            /* If there are no such field,
               return infinity */
            if (match == -1)
                return int.MAX;

            /* Increase irrelevance by
               match beginning index */
            irrelevance += match - field_beginning[matching_field];

            /* Cut the field */
            field_beginning[matching_field] = match + term.length;
        }

        /* Increase irrelevance by sum of
           lengths of first non-matched fields */
        for (var i = 0; i < field_beginning.length && field_beginning[i] == 0; i++)
            irrelevance += fields[i].length;

        /* Return the result */
        return irrelevance;
    }
}

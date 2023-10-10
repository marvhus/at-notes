Note :: struct {
    name: string; // note name
    text: string; // entire line
    line: u32; // line number @Note should this start from 0 or 1?
}

main :: () {
    args := get_command_line_arguments();
    if args.count < 2 {
        log_error("Not enough arguments. % <file>\n", args[0]);
        exit(1);
    }

    path := args[1];

    // @ToDo make this use arguments for path to file
    // @ToDo allow for giving a folder instead of a single file
    content, success := read_entire_file(path);
    if !success {
        log_error("Failed to read file from path '%'!\n", path);
        exit(1);
    }

    notes: Table(string, [..]Note);
    init(*notes);
    while content.count > 0 {
        found, note := next_note(*content);

        if !found continue;

        if table_contains(*notes, note.name) {
            found_notes_for_kind := table_find_pointer(*notes, note.name);
            array_add(found_notes_for_kind, note);
        } else {
            found_notes_for_kind: [..]Note;
            array_add(*found_notes_for_kind, note);
            table_set(*notes, note.name, found_notes_for_kind);
        }
    }

    for notes_for_kind, name: notes {
        print("@%\n", name);
        for note: notes_for_kind {
            print("- %\n", note);
        }
    }
}

line_number: u32 = 1;
next_note :: (content: *string) -> bool, Note {
    next :: (str: *string) {
        if str.count <= 0 return; // empty
        str.data += 1;
        str.count -= 1;
    }
    peek :: (str: *string, count := 0) -> u8 {
        if count >= str.count return 0; // ya looked too far.
        return str.data[count];
    }

    // ignore non comment
    for 0..content.count-1 {
        // @Note should implement block comments?
        if peek(content, 0) == #char "/" 
        && peek(content, 1) == #char "/" {
            break;
        }
        if peek(content) == #char "\n" then line_number += 1;
        next(content);
    }

    // check if at end of file
    if content.count == 0 return false, .{};

    // gather comment content
    text: [..]u8;
    while peek(content) != #char "\n" && content.count > 0 { // @ToDo support windows
        array_add(*text, peek(content));
        next(content);
    }

    // extract note name
    // @ToDo suppeort multiple notes in same comment
    reading_note := false;
    name: [..]u8;
    for c: text {
        if reading_note {
            c = to_lower(c); // ignore case
            if !is_alpha(c) break; // end of note
            array_add(*name, c);
        } else {
            if c == #char "@" then reading_note = true; // start of note
        }
    }
    if name.count == 0 return false, .{};

    note := Note.{
        name = to_string(name),
        text = to_string(text),
        line = line_number,
    };
    line_number += 1;

    return true, note;
}

#import "Hash_Table";
#import "Basic";
#import "File";

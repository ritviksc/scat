#!/usr/bin/env gawk 

@load "filefuncs" # Load metadata extension


BEGIN {
	
	print "Starting code analysis...";
	
	#Special Comments
	todo;
	note;
	fixme;
	bug;

	# Metadata variables
	loc; # Lines Of Code
	file_size;
	file_ext;

	# Preprocessing variables
	system_hdrs; # <>
	user_hdrs;   # ""
	pragma_guards;
	if_guard;
	ifdef_guard;
	ifndef_guard;
	else_guard;
	elif_guard;
	endif_guard;

	# Comment variables
	sl_comments;
	ml_comments;
        in_string = 0;
        in_block = 0;
}

# Get file metadata at start
FNR == 1 {
    if (FILENAME == "-") {
        print "No filename (stdin); metadata unavailable";
        exit 1;
    }

    if (stat(FILENAME, st) == 0) {
        print "Analyzing:", FILENAME
        file_size = st["size"];
	# Get extension
	n = split(FILENAME,a,".",sep);
	if (n != 0) {
		file_ext = a[n];
	}
    } else {
        print "Error getting file metadata for", FILENAME;
        print "Exiting...";
        exit 1;
    }

}

{
	if ($0 !~ /^$/) # Non empty-line
	{	# Header and preprocessing analytics
		# ---------------------------------------

		# Check for system headers <...>
		if ($0 ~ /^[[:space:]]*#[[:space:]]*include[[:space:]]*[<][^>]+\.h[>]/)
		{
			system_hdrs++;
			# Check for // single line comment 
			if ($0 ~ /\/\//){
				sl_comments++;
			# Check for /* */ single line comment
			} else if ($0 ~ /\/\*[[:space:]]*[^*]*[[:space:]]*\*\//){
				sl_comments++;
			}
			next;
		} 
		
		# Check for user headers "..."
		if ($0 ~ /^[[:space:]]*#[[:space:]]*include[[:space:]]*[<][^>]+\.h[>]/) {

			user_hdrs++;
			# Check for // single line comment
                        if ($0 ~ /\/\//){
                                sl_comments++;
                        # Check for /* */ single line comment
                        } else if ($0 ~ /\/\*[[:space:]]*[^*]*[[:space:]]*\*\//){
                                sl_comments++;
                        }
                        next;
		}

		# Check for #if 
		if ($0 ~ /^[[:space:]]*#[[:space:]]*if([[:space:]]+|\()[^[:space:]].*([[:space:]]*\/\/.*)?$/)
		{
			if_guard++;
			# Check for // single line comment
                        if ($0 ~ /\/\//){
                                sl_comments++;
                        # Check for /* */ single line comment
                        } else if ($0 ~ /\/\*[[:space:]]*[^*]*[[:space:]]*\*\//){
                                sl_comments++;
                        }
                        next;
		}

		# Check for #ifdef
                if ($0 ~ /^[[:space:]]*#[[:space:]]*ifdef([[:space:]]+|\()[^[:space:]].*([[:space:]]*\/\/.*)?$/)
                {
                        ifdef_guard++;
                        # Check for // single line comment
                        if ($0 ~ /\/\//){
                                sl_comments++;
                        # Check for /* */ single line comment
                        } else if ($0 ~ /\/\*[[:space:]]*[^*]*[[:space:]]*\*\//){
                                sl_comments++;
                        }
                        next;
                }

		# Check for #ifndef
                if ($0 ~ /^[[:space:]]*#[[:space:]]*ifndef([[:space:]]+|\()[^[:space:]].*([[:space:]]*\/\/.*)?$/)
                {
                        ifndef_guard++;
                        # Check for // single line comment
                        if ($0 ~ /\/\//){
                                sl_comments++;
                        # Check for /* */ single line comment
                        } else if ($0 ~ /\/\*[[:space:]]*[^*]*[[:space:]]*\*\//){
                                sl_comments++;
                        }
                        next;
                }
		
		# Check for #elif
		if ($0 ~ /^[[:space:]]*#[[:space:]]*elif([[:space:]]+|\()[^[:space:]].*([[:space:]]*\/\/.*)?$/)
                {
                        elif_guard++;
			# Check for // single line comment
                        if ($0 ~ /\/\//){
                                sl_comments++;
                        # Check for /* */ single line comment
                        } else if ($0 ~ /\/\*[[:space:]]*[^*]*[[:space:]]*\*\//){
                                sl_comments++;
                        }
                        next;
                }

		#Check for #else
		if ($0 ~ /^[[:space:]]*#[[:space:]]*else([[:space:]]*(\/\/.*)?$)/)
                {
			else_guard++;
			# Check for // single line comment
                        if ($0 ~ /\/\//){
                                sl_comments++;
                        # Check for /* */ single line comment
                        } else if ($0 ~ /\/\*[[:space:]]*[^*]*[[:space:]]*\*\//){
                                sl_comments++;
                        }
                        next;
                }

		# Check for #endif
		if ($0 ~ /^[[:space:]]*#[[:space:]]*endif([[:space:]]*(\/\/.*)?$)/)
                {
                        endif_guard++;
			# Check for // single line comment
                        if ($0 ~ /\/\//){
                                sl_comments++;
                        # Check for /* */ single line comment
                        } else if ($0 ~ /\/\*[[:space:]]*[^*]*[[:space:]]*\*\//){
                                sl_comments++;
                        }
                        next;
                }

		# Check for pragma once
		if ($0 ~ /^[[:space:]]*#[[:space:]]*pragma[[:space:]]+once([[:space:]]*(\/\/.*)?$)/)
		{
			pragma_guards++;
			# Check for // single line comment
                        if ($0 ~ /\/\//){
                                sl_comments++;
                        # Check for /* */ single line comment
                        } else if ($0 ~ /\/\*[[:space:]]*[^*]*[[:space:]]*\*\//){
                                sl_comments++;
                        }
			next;
		}

		# Special comment count
                # tode,fixme,bug,note
                if ($0 ~ /^\/\/[[:space:]]*[Tt][Oo][Dd][Oo].*/)
                        todo++;


                if ($0 ~ /^\/\/[[:space:]]*[Bb][Uu][Gg].*/)
                        bug++;


                if ($0 ~ /^\/\/[[:space:]]*[Ff][Ii][Xx].*/)
                        fixme++;


                if ($0 ~ /^\/\/[[:space:]]*[No][Oo][Tt][Ee].*/)
                        note++;

		# Checking for comments
		
	        line = $0

    		for (i = 1; i <= length(line); i++) {
        		char = substr(line, i, 1);
        		next_char = substr(line, i+1, 1);

        		# Exit string
        		if (in_string && char == "\"") {
            			in_string = 0;
            			continue;
        		}

        		# Inside string: ignore everything
        		if (in_string)
            			continue;

        		#Enter string
        		if (!in_block && char == "\"") {
            			in_string = 1;
            			continue;
        		}

        		# End block comment		
        		if (in_block && char == "*" && next_char == "/") {
            			in_block = 0;
            			i++;
            			continue;
        		}

        		# Inside block comment
        		if (in_block)
            			continue;

        		# Single-line comment
        		if (char == "/" && next_char == "/") {
            			sl_comments++;
            			next;
        		}

       			 # Start block comment
        		if (char == "/" && next_char == "*") {
            			in_block = 1;
            			ml_comments++;
            		 	i++;
        		}
    
		}
	
		loc++;
	}
}

END {
	print "-----    Metadata    -----";
	print "";
	print "File:", FILENAME;
	print "Size of file:", file_size , "B";
	if (file_ext != FILENAME){
		print "File type:", file_ext,"file";
	} else {
		print "File type: N/A";
	}
	print "";
	print "----- Code Analytics -----";
	print "";
	print "Lines Of Code (LOC): ", loc;
	print "Total line(s): ", NR;
	print "Blank line(s): ", (NR - loc);
	print "";
	#-------------------PREPROCESSING--------------------------
	print "Includes:"
	print " System header(s) included: ", system_hdrs;
	print " User header(s) included: ", user_hdrs;
	print " Total include(s): ", system_hdrs + user_headers;
	print " Total if directives: ", if_guard;
	print " Total ifdef directives: ", ifdef_guard;
	print " Total ifndef directives: ", ifndef_guard;
	print " Total elif directives: ", elif_guard;
	print " Total else directives: ", else_guard;
	print " Total endif directives: ", endif_guard;
	if (if_guard + ifndef_guard + ifdef_guard > endif_guard){
		print " WARNING: Likely missing a #endif";
	} else if (if_guard + ifndef_guard + ifdef_guard < endif_guard) {
		print " WARNING: Likely an extra #endif";
	}
	if (pragma_guards != 0){
		print " Pragma Guard(s): ", pragma_guards;
	}
	#-------------------COMMENT---------------------------
	print "Comments:"
	print " Single-line: ", sl_comments;
	print " Multi-line: ", ml_comments;
	print " Comment density: ", (sl_comments + ml_comments)/loc * 100,"%";
	print " FIXME comments: ", fixme;
	print " TODO comments: ", todo;
	print " BUG comments: ", bug;
	print " NOTE comments: ", note;
}

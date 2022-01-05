note
	description: "Summary description for {NEO4J_GRAPHDATABASE}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	NEO4J_GRAPHDATABASE


create
   make

feature

		db_url : STRING
		authentication_username : STRING
		authentication_password : STRING

		make (url : STRING)
		require
			not_empty : url.count > 0
		do
			db_url := url
			authentication_username := ""
			authentication_password := ""
		end

		set_user_name ( u : STRING)
		do
			authentication_username := u
		end

		set_pass ( p : STRING)
		do
			authentication_password := p
		end

		send_command_to_database ( neo4j_command : STRING) : STRING
		local
			cl: DEFAULT_HTTP_CLIENT
			sess: HTTP_CLIENT_SESSION
			ctx: HTTP_CLIENT_REQUEST_CONTEXT
--			l : LOGGER
		do
--			create l
			Result :=""
			did_latest_db_request_fail := true

				-- GET REQUEST WITH AUTHENTICATION, see http://browserspy.dk/password.php
				-- check header WWW-Authenticate is received (authentication successful)
			create cl
			sess := cl.new_session (db_url)
			sess.set_credentials (authentication_username, authentication_password) -- Production databases
	    sess.add_header("Content-Type", "application/json")
	    sess.add_header("Accept", "application/json;charset=UTF-8")
	    sess.add_header("X-Stream", "true")  -- To improve performance according to chapter 2 on this page: https://neo4j.com/docs/rest-docs/current/


	    sess.set_header_received_verbose (true)
	    sess.set_header_sent_verbose (true)


			create ctx.make_with_credentials_required
			ctx.add_header ("Content-Type", "application/json")
			ctx.add_header ("Accept", "application/json;charset=UTF-8")
			ctx.set_upload_data (neo4j_command)

			from ctx.headers.start
			until
				ctx.headers.after
			loop
				ctx.headers.forth
			end

			if attached sess.get ("/db/data/transaction/commit", ctx) as res then
				if attached {READABLE_STRING_8} res.body as l_body then
					if l_body.has_substring ("%"errors%":[]" ) then
						did_latest_db_request_fail := false
						Result := l_body
					end
				end
			end
		end


  did_latest_db_request_fail : BOOLEAN


-- Feature used to convert Cypher result strings to Eiffel string. Might not be a comprehensive list
		replace_escaped_characters ( in :STRING) : STRING  -- Note: Escape sequences from this page, heading "2.3.2 Note on string literals", in the neo4j documentation: https://neo4j.com/docs/cypher-manual/current/syntax/expressions/
		local
			escape_ch_found : BOOLEAN
			res : STRING
		do
			create res.make (in.count)
			across in as ch  loop
				if not escape_ch_found and ch.item.is_equal ('\') then
					escape_ch_found := true
				else
					if escape_ch_found then
						escape_ch_found := false
						if ch.item.is_equal ('n') then
							res.append_code (10)
						elseif ch.item.is_equal ('t') then
							res.append_code (9)
						elseif ch.item.is_equal ('%'') then
							res.append_character (ch.item)
						elseif ch.item.is_equal ('\') then
							res.append_character (ch.item)
						elseif ch.item.is_equal ('%"') then
							res.append_character (ch.item)
						else -- We do not know what kind of escape sequence that we got so we just forward it. Also the \ can be just forwarded
							res.append_character ('\')
							res.append_character (ch.item)
						end

					else -- Normal character
						res.append_character (ch.item)
					end
				end
			end

			Result := res
		end

-- To be used for strings that are added to a Cypher command and might include escape characters, Eiffel language and/or Cypher lagnuage escape characters.
	escape_characters ( in :STRING) : STRING  -- Note: Escape sequences from this page, heading "2.3.2 Note on string literals", in the neo4j documentation: https://neo4j.com/docs/cypher-manual/current/syntax/expressions/
												  -- Note: Eiffel escape sequeces are described at this page: https://www.eiffel.org/doc/eiffel/Eiffel_programming_language_syntax

		local
			res : STRING
			escape_ch_found : BOOLEAN
		do
			create res.make (in.count)
			across in as ch  loop
				if not escape_ch_found and ch.item.is_equal ('\') then
					escape_ch_found := true
				else
					if escape_ch_found then
						escape_ch_found := false
						if ch.item.is_equal ('n') or ch.item.is_equal ('t') then
							res.append_character ('\')
							res.append_character (ch.item)
						elseif  ch.item.is_equal ('%"') then
							res.append_character ('\')
							res.append_character ('\')
							res.append_character ('\')
							res.append_character (ch.item)
						elseif ch.item.is_equal ('\') then
							res.append_character ('\')
							res.append_character ('\')
							res.append_character ('\')
							res.append_character ('\')
						else
							res.append_character ('\')
							res.append_character ('\')
							res.append_character (ch.item)
						end
					else
						if ch.item.is_equal ('%'') then -- Since JSON concider ' as a normal character it does not need to be escaped but I need to escape it in the Cypher, but \ is an escape character so I need to escape the \ with another \
							res.append_character ('\')
							res.append_character ('\')
							res.append_character (ch.item)
						else
							res.append_character (ch.item)
						end
					end
				end
			end
			if escape_ch_found then -- Last character in "in" was a \
				res.append_character ('\')
				res.append_character ('\')

			end
			Result := res
		end


end

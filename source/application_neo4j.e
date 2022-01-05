note
	description: "db_example application root class"
	date: "$Date$"
	revision: "$Revision$"

class
	APPLICATION_NEO4J

inherit
	ARGUMENTS_32

create
	make

feature {NONE} -- Initialization

	make
			-- Run application.
			local
				db : NEO4J_GRAPHDATABASE
				result_string_from_db : STRING
		do
			create db.make("http://localhost:7474")
			db.set_user_name ("neo4j")
			db.set_pass ("password")
			result_string_from_db := db.send_command_to_database ("{  %"statements%" : [ {    %"statement%" : %"MERGE (n:node {node_name: 'NodeName' } ) RETURN id(n)%"  } ]}")

			--| Add your code here
			print ("Respons from neo4j database %N" + result_string_from_db)
		end

end

# neo4j-eiffel-driver
Neo4j Driver for Eiffel

Tested with neo4j database version 4.1.3 and ISE Eiffel Studio version 19.05



# Example


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

			print ("Respons from neo4j database %N" + result_string_from_db)
		end

end

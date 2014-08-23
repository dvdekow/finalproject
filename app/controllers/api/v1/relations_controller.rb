class Api::V1::RelationsController < Api::V1::BaseController
	def index
	  # initialize neograohy
      @neo = Neography::Rest.new
      queryRelation = @neo,execute_query("match (a)-[r]-(b) return a,b")

      respond_with("relation" => queryRelation, :message => 'OK')
	end

	def new
	end

	def create
	  # initiate neography
  	  @neo = Neography::Rest.new
      # set default to avoid null params
      userid = 'default'
      itemid = '123'
      type = 'unknown'
      # capturing parameter
      unless params[:itemid].nil?
        itemid = params[:itemid]
      end
    
      unless params[:userid].nil?
  	    userid = params[:userid]
      end

      unless params[:type].nil?
    	type = params[:type]
      end

      queryBuyer = @neo.execute_query("match (n) where n.userid = '#{userid}' return n")

      if queryBuyer["data"].empty?
        nodeBuyer = @neo.create_node("userid" => userid)
        labeledBuyer = @neo.add_label(nodeBuyer, "Buyer")
      else
        nodeBuyer = queryBuyer["data"]
      end

      queryItem = @neo.execute_query("match (n) where n.itemid = '#{itemid}' return n")

      if queryItem["data"].empty?
        nodeItem = @neo.create_node("itemid" => itemid)
        labeledItem = @neo.add_label(nodeItem, "Item")
      else
        nodeItem = queryItem["data"]
      end

      # create relationship
      rel = @neo.create_relationship("rated", nodeBuyer, nodeItem)
      # return buyer node id, for updating when userid acquired

      # labelnode = @neo.add_label(unlabelnode, "Buyer")
      # newnode = @neo.create_node("userid" => "davideko")
      unless rel.nil?
      	if type.eql? "look"
      	  wrel = @neo.set_relationship_properties(rel, {"rating" => 1, "type" => type})
      	  render json: {:node => wrel, :message => 'look relation has been created'}
        else
      	  wrel = @neo.set_relationship_properties(rel, {"rating" => 2, "type" => type})
      	  render json: {:node => wrel, :message => 'purchase relation has been created'}
        end
  	  else
        render json: {:message => 'Node has not been created'}
      end
	end

	def show
		userid = params[:id]
		@neo = Neography::Rest.new
		queryRelation = @neo.execute_query("match (n) where n.userid = '#{userid}' return n")
		#get all relationship
		result = @neo.get_node_relationships(queryRelation["data"], "out", "rated");

		render json: {:relationship =>result, :message => 'OK'}
	end

	def edit
	end

	def update
		userid = params[:id]
		@neo = Neography::Rest.new
		# get the node
		queryNode = @neo.execute_query("match (n) where n.userid = '#{userid}' return n")
		# get the relationship
		relation = @neo.get_node_relationships(queryNode["data"]);

		arrRel = Array.new
		time = Time.new
		# update attribut
		relation.each do |r|
			if r["type"].eql? "rated" 
			  # arrRel << @neo.set_relationship_properties(r, {"rating" => 1})
			  arrRel << @neo.set_relationship_properties(r, {"created_at" => time.inspect})
			  arrRel << @neo.set_relationship_properties(r, {"updated_at" => time.inspect})
			else
			  arrRel << @neo.set_relationship_properties(r, {"rating" => 2})
			end
		end

		render json: {:relationship => arrRel, :message => 'OK' }

	end

	def destroy
	end
end
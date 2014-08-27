require 'rubygems'
require 'neography'

class Collect
  def initialize
  	@neo = Neography::Rest.new
  end

  def relation(usr,itm,tp)
  	time = Time.new
  	userid = usr
    itemid = itm
    type = tp

    queryBuyer = @neo.execute_query("match (n) where n.userid = '#{userid}' return n")

    if queryBuyer["data"].empty?
      nodeBuyer = @neo.create_node("userid" => userid)
      labeledBuyer = @neo.add_label(nodeBuyer, "Buyer")
      labeledBuyer =  @neo.set_node_properties(nodeBuyer, { "created_at" => time.inspect })
	  labeledBuyer =  @neo.set_node_properties(nodeBuyer, { "updated_at" => time.inspect })
    else
      nodeBuyer = queryBuyer["data"]
    end

    queryItem = @neo.execute_query("match (n) where n.itemid = '#{itemid}' return n")

    if queryItem["data"].empty?
      nodeItem = @neo.create_node("itemid" => itemid)
      labeledItem = @neo.add_label(nodeItem, "Item")
      labeledItem =  Neo.set_node_properties(nodeItem, { "created_at" => time.inspect })
	  labeledItem =  Neo.set_node_properties(nodeItem, { "updated_at" => time.inspect })
    else
      nodeItem = queryItem["data"]
    end

    # create relationship
    rel = @neo.create_relationship("rated", nodeBuyer, nodeItem)
    # return buyer node id, for updating when userid acquired

    unless rel.nil?
      if type.eql? "look"
        wrel = @neo.set_relationship_properties(rel, {"rating" => 1, "type" => type})
        puts "its look"
      else
        wrel = @neo.set_relationship_properties(rel, {"rating" => 2, "type" => type})
        puts "its purchase"
      end
        wrel = @neo.set_relationship_properties(rel, {"created_at" => time.inspect})
		wrel = @neo.set_relationship_properties(rel, {"updated_at" => time.inspect})
    else
        puts "failed"
    end
  end
end
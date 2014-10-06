require 'rubygems'
require 'neography'

class Collect
  def initialize
  	@neo = Neography::Rest.new
  end

  def create_node(tipe,nodeid)
    # time = Time.new
    node = ""
    if tipe == "buyer"
      node = @neo.create_node("userid" => nodeid)
      node = @neo.add_label(node, "Buyer")
    else
      node = @neo.create_node("itemid" => nodeid)
      node = @neo.add_label(node, "Item")
    end

    return node
  end

  def relation(usr,itm,tp)
  	time = Time.new
  	userid = usr
    itemid = itm
    type = tp

    queryBuyer = @neo.execute_query("match (n) where n.userid = '#{userid}' return n")

    if queryBuyer["data"].empty?
      nodeBuyer = create_node("buyer", userid)
    else
      nodeBuyer = queryBuyer["data"]
    end

    queryItem = @neo.execute_query("match (n) where n.itemid = '#{itemid}' return n")

    if queryItem["data"].empty?
      nodeItem = create_node("item", itemid)
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
        wrel = @neo.set_relationship_properties(rel, {"created_at" => time.inspect,"updated_at" => time.inspect})
    else
        puts "failed"
    end
  end
end
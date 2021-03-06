require 'rubygems'
require 'neography'

class Collect
  def initialize
  	@neo = Neography::Rest.new
  end

  def create_node(tipe,nodeid)
    time = Time.new
    node = ""
    if tipe == "buyer"
      node = @neo.create_node("userid" => nodeid)
      label_node = @neo.add_label(node, "Buyer")
      
      prop_node = @neo.set_node_properties(node, {"created_at" => time.inspect, "updated_at" => time.inspect})

      @neo.execute_query("CREATE INDEX ON :Buyer(userid)")
    else
      node = @neo.create_node("itemid" => nodeid)
      label_node = @neo.add_label(node, "Item")
      
      prop_node = @neo.set_node_properties(node, {"created_at" => time.inspect, "updated_at" => time.inspect})
      
      @neo.execute_query("CREATE INDEX ON :Item(itemid)")
    end

    return node
  end

  def relation(usr,itm,tp)
  	time = Time.new
  	userid = usr
    itemid = itm
    type = tp

    queryBuyer = @neo.execute_query("match (buyer:Buyer) where buyer.userid = '#{userid}' return buyer")

    if queryBuyer["data"].empty?
      nodeBuyer = create_node("buyer", userid)
    else
      nodeBuyer = queryBuyer["data"]
    end

    queryItem = @neo.execute_query("match (item:Item) where item.itemid = '#{itemid}' return item")

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
      else
        wrel = @neo.set_relationship_properties(rel, {"rating" => 2, "type" => type})
      end
        wrel = @neo.set_relationship_properties(rel, {"created_at" => time.inspect,"updated_at" => time.inspect})
    else
        puts "failed"
    end
  end
end
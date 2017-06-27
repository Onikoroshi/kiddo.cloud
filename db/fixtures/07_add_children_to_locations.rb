birch_lane = Location.find_by(name: "Birch Lane")
birch_lane.children << Child.find(1,2,3,4,5)

pine = Location.find_by(name: "Pine Avenue")
pine.children << Child.find(6)

hickory = Location.find_by(name: "Hickory Street")
hickory.children << Child.find(7)

maple = Location.find_by(name: "Maple Circle")
maple.children << Child.find(8)

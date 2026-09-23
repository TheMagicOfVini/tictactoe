# find_or_create_by! makes a second db:seed skip the players that exist
[
  { name: "Jeff Bezos", wins: 5, losses: 2, draws: 0 },
  { name: "Bill Gates", wins: 1, losses: 8, draws: 3 },
  { name: "Justin Trudeau", wins: 42, losses: 12, draws: 10 },
  { name: "Stephen Harper", wins: 25, losses: 22, draws: 10 },
  { name: "Elon Musk", wins: 11, losses: 3, draws: 9 }
].each do |attributes|
  Player.find_or_create_by!(name: attributes[:name]) do |player|
    player.assign_attributes(attributes.except(:name))
  end
end

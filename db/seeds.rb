# Create default categories for digital products
puts "Creating categories..."

categories = [
  { name: "Templates", description: "Document templates, spreadsheets, and productivity tools" },
  { name: "Graphics", description: "Images, logos, icons, and design assets" },
  { name: "eBooks", description: "Digital books, guides, and written content" },
  { name: "Music & Audio", description: "Audio files, sound effects, and music tracks" },
  { name: "Video", description: "Video files, tutorials, and motion graphics" },
  { name: "Software", description: "Applications, scripts, and code resources" },
  { name: "Education", description: "Courses, tutorials, and educational materials" },
  { name: "Art & Illustration", description: "Digital art, illustrations, and creative works" }
]

categories.each do |category_data|
  Category.find_or_create_by!(name: category_data[:name]) do |category|
    category.description = category_data[:description]
  end
end

puts "Created #{Category.count} categories"

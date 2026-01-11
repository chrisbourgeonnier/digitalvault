# Pagy initializer - minimal configuration
require "pagy/extras/overflow"

# Default items per page
Pagy::DEFAULT[:limit] = 12  # Show 12 products per page (works well with 3-column grid)

# When there are no items to paginate, return an empty pagy object
Pagy::DEFAULT[:overflow] = :empty_page

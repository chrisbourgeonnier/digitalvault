class ProductsController < ApplicationController
  before_action :authenticate_user!, except: [ :index, :show ]
  before_action :set_product, only: [ :show, :edit, :update, :destroy ]
  after_action :verify_authorized, except: [ :index ]

  def index
    products_scope = Product.all
                            .search_by_keyword(params[:search])
                            .min_price(params[:min_price])
                            .max_price(params[:max_price])
                            .by_category(params[:category_id])
                            .sorted_by(params[:sort])

    @pagy, @products = pagy(products_scope)
    @category = Category.find_by(id: params[:category_id]) if params[:category_id].present?
  end

  def show
    authorize @product
  end

  def new
    @product = Product.new
    authorize @product
  end

  def create
    @product = current_user.products.build(product_params)
    authorize @product

    if @product.save
      redirect_to @product, notice: "Product was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @product
  end

  def update
    authorize @product

    if @product.update(product_params)
      redirect_to @product, notice: "Product was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @product
    @product.destroy
    redirect_to products_url, notice: "Product was successfully destroyed."
  end

  private

  def set_product
    @product = Product.find(params[:id])
  end

  def product_params
    params.require(:product).permit(:title, :description, :price, :digital_file, :image, category_ids: [])
  end
end

class ProductsController < ApplicationController
  before_action :set_product, only: %i[ show buy ]
  before_action :set_seller_product, only: %i[ edit update destroy ]
  before_action :authenticate_user!, only: %i[ new create edit update destroy buy ]

  protect_from_forgery except: :webhook

  # GET /products or /products.json
  def index
    @products = Product.all
  end

  # GET /products/1 or /products/1.json
  def show
  end

  # GET /products/new
  def new
    @product = current_user.products.new
  end

  def buy
    session = Stripe::Checkout::Session.create({
      client_reference_id: @product.id,
      line_items: [{
        price: 'price_1QVG83G5j8M59D7ef0A8G1lH',
        quantity: 1,
      }],
      customer_email: current_user&.email,
      mode: 'payment',
      success_url: product_url(@product),
      cancel_url: product_url(@product),
    })

    redirect_to session.url, status: 303, allow_other_host: true
  end

  def webhook
    event = nil

    begin
      sig_header = request.env['HTTP_STRIPE_SIGNATURE']
      payload = request.body.read
      event = Stripe::Webhook.construct_event(payload, sig_header, ENV['STRIPE_WEBHOOK_ENDPOINT_SECRET'])
    rescue JSON::ParserError => e
      render json: { status: 400, error: e.message } and return
    rescue Stripe::SignatureVerificationError => e
      render json: { status: 400, error: e.message } and return
    end

    if event['type'] == 'checkout.session.completed'
      customer_email = event.data.object.customer_email
      product_id = event.data.object.client_reference_id

      customer = User.find_by(email: customer_email)
      purchase = customer.purchases.create(product_id: product_id)
    end

    render json: { status: 200 }
  end

  # GET /products/1/edit
  def edit
  end

  # POST /products or /products.json
  def create
    @product = current_user.products.new(product_params)

    respond_to do |format|
      if @product.save
        format.html { redirect_to @product, notice: "Product was successfully created." }
        format.json { render :show, status: :created, location: @product }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /products/1 or /products/1.json
  def update
    respond_to do |format|
      if @product.update(product_params)
        format.html { redirect_to @product, notice: "Product was successfully updated." }
        format.json { render :show, status: :ok, location: @product }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /products/1 or /products/1.json
  def destroy
    @product.destroy!

    respond_to do |format|
      format.html { redirect_to products_path, status: :see_other, notice: "Product was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    def set_seller_product
      @product = current_user.products.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to :root, alert: "You are not authorized to edit this product." and return
    end

    def set_product
      @product = Product.find(params[:id])
    end

    def product_params
      params.require(:product).permit(:title, :description, :price, :seller_id)
    end
end

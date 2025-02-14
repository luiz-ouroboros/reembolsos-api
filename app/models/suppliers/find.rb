class Suppliers::Find < UseCase
  attributes :current_user, :params, :id

  def call!
    supplier = Supplier.find((params[:id] || id).to_i)

    Success(:find_success, result: { supplier: supplier })
  end
end

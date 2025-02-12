module RequestHelpers
  def body
    JSON.parse(response.body)
  end
end
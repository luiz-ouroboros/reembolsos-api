module Types
  include Dry.Types()

  StringUntil255 = Types::Coercible::String.constrained(max_size: 255)
  Email = Types::Coercible::String.constrained(format: URI::MailTo::EMAIL_REGEXP)
  File = Types.Instance(::File) | Types.Instance(ActionDispatch::Http::UploadedFile)

  module Users
    Roles = Types::Coercible::String.enum(*User::ROLES)
  end

  module Tags
    Name = StringUntil255.constructor(&:upcase)
  end

  module Suppliers
    Name = StringUntil255.constructor(&:upcase)
  end

  module RefundRequests
    Status = Types::Coercible::String.enum(*RefundRequest::STATUSES)
  end
end

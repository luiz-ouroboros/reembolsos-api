class ContractScheme < Dry::Validation::Contract
  config.messages.load_paths << 'config/locales/errors.yml'
  config.messages.default_locale = :pt
end

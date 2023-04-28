# frozen_string_literal: true

json.array! @invoices, partial: 'invoices/invoice', as: :invoice

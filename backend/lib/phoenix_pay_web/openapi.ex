defmodule PhoenixPayWeb.OpenAPI do
  alias OpenApiSpex.{Operation, Parameter, RequestBody, Response, Schema}

  def spec do
    %OpenApiSpex.OpenApi{
      servers: [
        %OpenApiSpex.Server{url: "http://localhost:4000"},
        %OpenApiSpex.Server{url: "https://api.yourdomain.com"}
      ],
      info: %OpenApiSpex.Info{
        title: "Phoenix Pay API",
        description: "API de Pagamentos - PIX, Boleto, Cartão",
        version: "1.0.0"
      },
      paths: paths(),
      components: %OpenApiSpex.Components{
        schemas: schemas(),
        securitySchemes: %{
          "bearer" => %OpenApiSpex.SecurityScheme{
            type: "http",
            scheme: "bearer",
            bearerFormat: "JWT"
          }
        }
      }
    }
  end

  def paths do
    %{
      "/api/v1/auth/register" => %OpenApiSpex.PathItem{
        post: register_operation()
      },
      "/api/v1/auth/login" => %OpenApiSpex.PathItem{
        post: login_operation()
      },
      "/api/v1/payments" => %OpenApiSpex.PathItem{
        get: list_payments_operation(),
        post: create_payment_operation()
      },
      "/api/v1/payments/{id}" => %OpenApiSpex.PathItem{
        get: get_payment_operation()
      },
      "/api/v1/payments/{id}/confirm" => %OpenApiSpex.PathItem{
        post: confirm_payment_operation()
      },
      "/api/v1/payments/{id}/status" => %OpenApiSpex.PathItem{
        get: payment_status_operation()
      },
      "/api/v1/transactions" => %OpenApiSpex.PathItem{
        get: list_transactions_operation()
      },
      "/api/v1/transactions/{id}" => %OpenApiSpex.PathItem{
        get: get_transaction_operation()
      },
      "/api/v1/webhooks" => %OpenApiSpex.PathItem{
        get: list_webhooks_operation(),
        post: create_webhook_operation()
      },
      "/api/v1/webhooks/{id}" => %OpenApiSpex.PathItem{
        put: update_webhook_operation(),
        delete: delete_webhook_operation()
      },
      "/api/v1/webhooks/{id}/logs" => %OpenApiSpex.PathItem{
        get: webhook_logs_operation()
      },
      "/api/v1/stats" => %OpenApiSpex.PathItem{
        get: stats_operation()
      },
      "/api/v1/stats/user" => %OpenApiSpex.PathItem{
        get: user_stats_operation()
      }
    }
  end

  # Auth Operations
  defp register_operation do
    %Operation{
      tags: ["Auth"],
      summary: "Registrar novo usuário",
      requestBody: RequestBody.new("Dados do usuário", "application/json", Schema.ref(:UserRegister)),
      responses: %{
        201 => Response.new("Usuário criado com sucesso", "application/json", Schema.ref(:User)),
        400 => Response.new("Email já existe"),
        422 => Response.new("Dados inválidos")
      }
    }
  end

  defp login_operation do
    %Operation{
      tags: ["Auth"],
      summary: "Realizar login",
      requestBody: RequestBody.new("Credenciais", "application/json", Schema.ref(:UserLogin)),
      responses: %{
        200 => Response.new("Login bem-sucedido", "application/json", Schema.ref(:LoginResponse)),
        401 => Response.new("Credenciais inválidas"),
        404 => Response.new("Usuário não encontrado")
      }
    }
  end

  # Payment Operations
  defp list_payments_operation do
    %Operation{
      tags: ["Payments"],
      summary: "Listar pagamentos do usuário",
      security: [%{"bearer" => []}],
      parameters: [
        Parameter.new(:query, :status, :string, "Filtrar por status"),
        Parameter.new(:query, :limit, :integer, "Limite de resultados")
      ],
      responses: %{
        200 => Response.new("Lista de pagamentos", "application/json", Schema.ref(:PaymentList)),
        401 => Response.new("Não autorizado")
      }
    }
  end

  defp create_payment_operation do
    %Operation{
      tags: ["Payments"],
      summary: "Criar novo pagamento",
      security: [%{"bearer" => []}],
      requestBody: RequestBody.new("Dados do pagamento", "application/json", Schema.ref(:CreatePayment)),
      responses: %{
        201 => Response.new("Pagamento criado", "application/json", Schema.ref(:Payment)),
        400 => Response.new("Dados inválidos"),
        401 => Response.new("Não autorizado")
      }
    }
  end

  defp get_payment_operation do
    %Operation{
      tags: ["Payments"],
      summary: "Obter detalhes do pagamento",
      security: [%{"bearer" => []}],
      parameters: [Parameter.new(:path, :id, :string, "ID do pagamento")],
      responses: %{
        200 => Response.new("Detalhes do pagamento", "application/json", Schema.ref(:Payment)),
        401 => Response.new("Não autorizado"),
        404 => Response.new("Pagamento não encontrado")
      }
    }
  end

  defp confirm_payment_operation do
    %Operation{
      tags: ["Payments"],
      summary: "Confirmar pagamento",
      security: [%{"bearer" => []}],
      parameters: [Parameter.new(:path, :id, :string, "ID do pagamento")],
      responses: %{
        200 => Response.new("Pagamento confirmado", "application/json", Schema.ref(:Payment)),
        401 => Response.new("Não autorizado"),
        404 => Response.new("Pagamento não encontrado")
      }
    }
  end

  defp payment_status_operation do
    %Operation{
      tags: ["Payments"],
      summary: "Obter status do pagamento",
      security: [%{"bearer" => []}],
      parameters: [Parameter.new(:path, :id, :string, "ID do pagamento")],
      responses: %{
        200 => Response.new("Status do pagamento", "application/json", Schema.ref(:PaymentStatus)),
        401 => Response.new("Não autorizado"),
        404 => Response.new("Pagamento não encontrado")
      }
    }
  end

  # Transaction Operations
  defp list_transactions_operation do
    %Operation{
      tags: ["Transactions"],
      summary: "Listar transações",
      security: [%{"bearer" => []}],
      parameters: [
        Parameter.new(:query, :status, :string, "Filtrar por status"),
        Parameter.new(:query, :limit, :integer, "Limite de resultados")
      ],
      responses: %{
        200 => Response.new("Lista de transações", "application/json", Schema.ref(:TransactionList)),
        401 => Response.new("Não autorizado")
      }
    }
  end

  defp get_transaction_operation do
    %Operation{
      tags: ["Transactions"],
      summary: "Obter detalhes da transação",
      security: [%{"bearer" => []}],
      parameters: [Parameter.new(:path, :id, :string, "ID da transação")],
      responses: %{
        200 => Response.new("Detalhes da transação", "application/json", Schema.ref(:Transaction)),
        401 => Response.new("Não autorizado"),
        404 => Response.new("Transação não encontrada")
      }
    }
  end

  # Webhook Operations
  defp list_webhooks_operation do
    %Operation{
      tags: ["Webhooks"],
      summary: "Listar webhooks",
      security: [%{"bearer" => []}],
      responses: %{
        200 => Response.new("Lista de webhooks", "application/json", Schema.ref(:WebhookList)),
        401 => Response.new("Não autorizado")
      }
    }
  end

  defp create_webhook_operation do
    %Operation{
      tags: ["Webhooks"],
      summary: "Criar novo webhook",
      security: [%{"bearer" => []}],
      requestBody: RequestBody.new("Dados do webhook", "application/json", Schema.ref(:CreateWebhook)),
      responses: %{
        201 => Response.new("Webhook criado", "application/json", Schema.ref(:Webhook)),
        400 => Response.new("Dados inválidos"),
        401 => Response.new("Não autorizado")
      }
    }
  end

  defp update_webhook_operation do
    %Operation{
      tags: ["Webhooks"],
      summary: "Atualizar webhook",
      security: [%{"bearer" => []}],
      parameters: [Parameter.new(:path, :id, :string, "ID do webhook")],
      requestBody: RequestBody.new("Dados do webhook", "application/json", Schema.ref(:CreateWebhook)),
      responses: %{
        200 => Response.new("Webhook atualizado", "application/json", Schema.ref(:Webhook)),
        400 => Response.new("Dados inválidos"),
        401 => Response.new("Não autorizado"),
        404 => Response.new("Webhook não encontrado")
      }
    }
  end

  defp delete_webhook_operation do
    %Operation{
      tags: ["Webhooks"],
      summary: "Excluir webhook",
      security: [%{"bearer" => []}],
      parameters: [Parameter.new(:path, :id, :string, "ID do webhook")],
      responses: %{
        204 => Response.new("Webhook excluído"),
        401 => Response.new("Não autorizado"),
        404 => Response.new("Webhook não encontrado")
      }
    }
  end

  defp webhook_logs_operation do
    %Operation{
      tags: ["Webhooks"],
      summary: "Listar logs do webhook",
      security: [%{"bearer" => []}],
      parameters: [Parameter.new(:path, :id, :string, "ID do webhook")],
      responses: %{
        200 => Response.new("Logs do webhook", "application/json", Schema.ref(:WebhookLogList)),
        401 => Response.new("Não autorizado"),
        404 => Response.new("Webhook não encontrado")
      }
    }
  end

  # Stats Operations
  defp stats_operation do
    %Operation{
      tags: ["Stats"],
      summary: "Obter estatísticas gerais",
      security: [%{"bearer" => []}],
      responses: %{
        200 => Response.new("Estatísticas", "application/json", Schema.ref(:Stats)),
        401 => Response.new("Não autorizado")
      }
    }
  end

  defp user_stats_operation do
    %Operation{
      tags: ["Stats"],
      summary: "Obter estatísticas do usuário",
      security: [%{"bearer" => []}],
      responses: %{
        200 => Response.new("Estatísticas do usuário", "application/json", Schema.ref(:UserStats)),
        401 => Response.new("Não autorizado")
      }
    }
  end

  def schemas do
    %{
      User:
        Schema.new(%{
          type: :object,
          properties: %{
            id: %OpenApiSpex.Schema{type: :string, format: :uuid},
            email: %OpenApiSpex.Schema{type: :string, format: :email},
            created_at: %OpenApiSpex.Schema{type: :string, format: :"date-time"}
          },
          required: [:id, :email]
        }),
      UserRegister:
        Schema.new(%{
          type: :object,
          properties: %{
            email: %OpenApiSpex.Schema{type: :string, format: :email},
            password: %OpenApiSpex.Schema{type: :string, minLength: 6}
          },
          required: [:email, :password]
        }),
      UserLogin:
        Schema.new(%{
          type: :object,
          properties: %{
            email: %OpenApiSpex.Schema{type: :string, format: :email},
            password: %OpenApiSpex.Schema{type: :string}
          },
          required: [:email, :password]
        }),
      LoginResponse:
        Schema.new(%{
          type: :object,
          properties: %{
            token: %OpenApiSpex.Schema{type: :string},
            user: Schema.ref(:User)
          },
          required: [:token, :user]
        }),
      Payment:
        Schema.new(%{
          type: :object,
          properties: %{
            id: %OpenApiSpex.Schema{type: :string, format: :uuid},
            reference_id: %OpenApiSpex.Schema{type: :string},
            amount: %OpenApiSpex.Schema{type: :number, format: :decimal},
            description: %OpenApiSpex.Schema{type: :string},
            status: %OpenApiSpex.Schema{type: :string, enum: [:pending, :processing, :paid, :failed, :cancelled, :refunded]},
            payment_method: %OpenApiSpex.Schema{type: :string, enum: [:pix, :boleto, :card]},
            due_date: %OpenApiSpex.Schema{type: :string, format: :"date-time"},
            paid_at: %OpenApiSpex.Schema{type: :string, format: :"date-time"},
            created_at: %OpenApiSpex.Schema{type: :string, format: :"date-time"}
          },
          required: [:id, :amount, :description, :status]
        }),
      CreatePayment:
        Schema.new(%{
          type: :object,
          properties: %{
            amount: %OpenApiSpex.Schema{type: :number, format: :decimal},
            description: %OpenApiSpex.Schema{type: :string},
            payment_method: %OpenApiSpex.Schema{type: :string, enum: [:pix, :boleto, :card]},
            due_date: %OpenApiSpex.Schema{type: :string, format: :"date-time"},
            metadata: %OpenApiSpex.Schema{type: :object}
          },
          required: [:amount, :description]
        }),
      PaymentList:
        Schema.new(%{
          type: :object,
          properties: %{
            payments: %OpenApiSpex.Schema{
              type: :array,
              items: Schema.ref(:Payment)
            },
            total: %OpenApiSpex.Schema{type: :integer}
          }
        }),
      PaymentStatus:
        Schema.new(%{
          type: :object,
          properties: %{
            id: %OpenApiSpex.Schema{type: :string, format: :uuid},
            status: %OpenApiSpex.Schema{type: :string},
            updated_at: %OpenApiSpex.Schema{type: :string, format: :"date-time"}
          }
        }),
      Transaction:
        Schema.new(%{
          type: :object,
          properties: %{
            id: %OpenApiSpex.Schema{type: :string, format: :uuid},
            payment_id: %OpenApiSpex.Schema{type: :string, format: :uuid},
            type: %OpenApiSpex.Schema{type: :string, enum: [:debit, :credit, :transfer, :refund]},
            amount: %OpenApiSpex.Schema{type: :number, format: :decimal},
            status: %OpenApiSpex.Schema{type: :string, enum: [:success, :pending, :failed]},
            external_id: %OpenApiSpex.Schema{type: :string},
            error_message: %OpenApiSpex.Schema{type: :string},
            created_at: %OpenApiSpex.Schema{type: :string, format: :"date-time"}
          },
          required: [:id, :type, :amount, :status]
        }),
      TransactionList:
        Schema.new(%{
          type: :object,
          properties: %{
            transactions: %OpenApiSpex.Schema{
              type: :array,
              items: Schema.ref(:Transaction)
            },
            total: %OpenApiSpex.Schema{type: :integer}
          }
        }),
      Webhook:
        Schema.new(%{
          type: :object,
          properties: %{
            id: %OpenApiSpex.Schema{type: :string, format: :uuid},
            url: %OpenApiSpex.Schema{type: :string, format: :uri},
            events: %OpenApiSpex.Schema{type: :array, items: %OpenApiSpex.Schema{type: :string}},
            is_active: %OpenApiSpex.Schema{type: :boolean},
            created_at: %OpenApiSpex.Schema{type: :string, format: :"date-time"}
          },
          required: [:id, :url, :events]
        }),
      CreateWebhook:
        Schema.new(%{
          type: :object,
          properties: %{
            url: %OpenApiSpex.Schema{type: :string, format: :uri},
            events: %OpenApiSpex.Schema{type: :array, items: %OpenApiSpex.Schema{type: :string}},
            is_active: %OpenApiSpex.Schema{type: :boolean}
          },
          required: [:url, :events]
        }),
      WebhookList:
        Schema.new(%{
          type: :object,
          properties: %{
            webhooks: %OpenApiSpex.Schema{
              type: :array,
              items: Schema.ref(:Webhook)
            }
          }
        }),
      WebhookLog:
        Schema.new(%{
          type: :object,
          properties: %{
            id: %OpenApiSpex.Schema{type: :string, format: :uuid},
            webhook_id: %OpenApiSpex.Schema{type: :string, format: :uuid},
            status_code: %OpenApiSpex.Schema{type: :integer},
            response_body: %OpenApiSpex.Schema{type: :string},
            created_at: %OpenApiSpex.Schema{type: :string, format: :"date-time"}
          }
        }),
      WebhookLogList:
        Schema.new(%{
          type: :object,
          properties: %{
            logs: %OpenApiSpex.Schema{
              type: :array,
              items: Schema.ref(:WebhookLog)
            }
          }
        }),
      Stats:
        Schema.new(%{
          type: :object,
          properties: %{
            total_payments: %OpenApiSpex.Schema{type: :integer},
            total_revenue: %OpenApiSpex.Schema{type: :number, format: :decimal},
            paid_payments: %OpenApiSpex.Schema{type: :integer},
            failed_payments: %OpenApiSpex.Schema{type: :integer}
          }
        }),
      UserStats:
        Schema.new(%{
          type: :object,
          properties: %{
            user_id: %OpenApiSpex.Schema{type: :string, format: :uuid},
            total_payments: %OpenApiSpex.Schema{type: :integer},
            total_spent: %OpenApiSpex.Schema{type: :number, format: :decimal},
            successful_payments: %OpenApiSpex.Schema{type: :integer},
            failed_payments: %OpenApiSpex.Schema{type: :integer}
          }
        })
    }
  end
end

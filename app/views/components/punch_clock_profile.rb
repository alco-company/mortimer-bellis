class PunchClockProfile < ApplicationComponent
  include Phlex::Rails::Helpers::ButtonTag
  include Phlex::Rails::Helpers::FormWith
  include Phlex::Rails::Helpers::HiddenField

  attr_accessor :employee

  def initialize(employee: nil)
    @employee = employee || false
  end

  def view_template(&block)
    form_with url: helpers.pos_employee_url(api_key: employee.access_token), method: :put, class: "pb-32" do
      div(class: "mx-4 my-2 space-y-12 sm:space-y-16 ") do
        div do
          h2(class: "text-base font-semibold leading-7 text-gray-900") do
            "Profile"
          end
          p(class: "mt-1 max-w-2xl text-sm leading-6 text-gray-600") do
            "This information will be displayed publicly so be careful what you share."
          end
          div(
            class:
              "mt-10 space-y-8 border-b border-gray-900/10 pb-12 sm:space-y-0 sm:divide-y sm:divide-gray-900/10 sm:border-t sm:pb-0"
          ) do
            div(
              class: "sm:grid sm:grid-cols-3 sm:items-start sm:gap-4 sm:py-6"
            ) do
              whitespace
              label(
                for: "name",
                class:
                  "block text-sm font-medium leading-6 text-gray-900 sm:pt-1.5"
              ) { helpers.t(".name") }
              div(class: "mt-2 sm:col-span-2 sm:mt-0") do
                div(
                  class:
                    "flex rounded-md shadow-sm ring-1 ring-inset ring-gray-300 focus-within:ring-2 focus-within:ring-inset focus-within:ring-indigo-600 sm:max-w-md"
                ) do
                  whitespace
                  input(
                    name: "employee[name]",
                    id: "employee_name",
                    value: employee.name,
                    autocomplete: "name",
                    class:
                      "block flex-1 border-0 bg-transparent py-1.5 pl-2 text-gray-900 placeholder:text-gray-400 focus:ring-0 sm:text-sm sm:leading-6",
                    placeholder: "janesmith"
                  )
                end
              end
            end
            div(
              class: "sm:grid sm:grid-cols-3 sm:items-start sm:gap-4 sm:py-6"
            ) do
              whitespace
              label(
                for: "description",
                class:
                  "block text-sm font-medium leading-6 text-gray-900 sm:pt-1.5"
              ) { helpers.t(".description") }
              div(class: "mt-2 sm:col-span-2 sm:mt-0") do
                whitespace
                textarea(
                  id: "employee_description",
                  name: "employee[description]",
                  rows: "3",
                  class:
                    "block w-full max-w-2xl rounded-md border-0 py-1.5 text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-indigo-600 sm:text-sm sm:leading-6"
                ) do
                  plain employee.description
                end
                p(class: "mt-3 text-sm leading-6 text-gray-600") do
                  "Write a few sentences about yourself."
                end
              end
            end
            # div(
            #   class: "sm:grid sm:grid-cols-3 sm:items-center sm:gap-4 sm:py-6"
            # ) do
            #   whitespace
            #   label(
            #     for: "photo",
            #     class: "block text-sm font-medium leading-6 text-gray-900"
            #   ) { "Photo" }
            #   div(class: "mt-2 sm:col-span-2 sm:mt-0") do
            #     div(class: "flex items-center gap-x-3") do
            #       whitespace
            #       whitespace
            #       button(
            #         type: "button",
            #         class:
            #           "rounded-md bg-white px-2.5 py-1.5 text-sm font-semibold text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 hover:bg-gray-50"
            #       ) { "Change" }
            #     end
            #   end
            # end
            # div(
            #   class: "sm:grid sm:grid-cols-3 sm:items-start sm:gap-4 sm:py-6"
            # ) do
            #   whitespace
            #   label(
            #     for: "cover-photo",
            #     class:
            #       "block text-sm font-medium leading-6 text-gray-900 sm:pt-1.5"
            #   ) { "Cover photo" }
            #   div(class: "mt-2 sm:col-span-2 sm:mt-0") do
            #     div(
            #       class:
            #         "flex max-w-2xl justify-center rounded-lg border border-dashed border-gray-900/25 px-6 py-10"
            #     ) do
            #       div(class: "text-center") do
            #         whitespace
            #         div(class: "mt-4 flex text-sm leading-6 text-gray-600") do
            #           whitespace
            #           label(
            #             for: "file-upload",
            #             class:
            #               "relative cursor-pointer rounded-md bg-white font-semibold text-indigo-600 focus-within:outline-none focus-within:ring-2 focus-within:ring-indigo-600 focus-within:ring-offset-2 hover:text-indigo-500"
            #           ) do
            #             whitespace
            #             span { "Upload a file" }
            #             whitespace
            #             input(
            #               id: "file-upload",
            #               name: "file-upload",
            #               type: "file",
            #               class: "sr-only"
            #             )
            #             whitespace
            #           end
            #           p(class: "pl-1") { "or drag and drop" }
            #         end
            #         p(class: "text-xs leading-5 text-gray-600") do
            #           "PNG, JPG, GIF up to 10MB"
            #         end
            #       end
            #     end
            #   end
            # end
          end
        end
        div do
          h2(class: "text-base font-semibold leading-7 text-gray-900") do
            "Personal Information"
          end
          p(class: "mt-1 max-w-2xl text-sm leading-6 text-gray-600") do
            "Use a permanent address where you can receive mail."
          end
          div(
            class:
              "mt-10 space-y-8 border-b border-gray-900/10 pb-12 sm:space-y-0 sm:divide-y sm:divide-gray-900/10 sm:border-t sm:pb-0"
          ) do
            # div(
            #   class: "sm:grid sm:grid-cols-3 sm:items-start sm:gap-4 sm:py-6"
            # ) do
            #   whitespace
            #   label(
            #     for: "first-name",
            #     class:
            #       "block text-sm font-medium leading-6 text-gray-900 sm:pt-1.5"
            #   ) { "First name" }
            #   div(class: "mt-2 sm:col-span-2 sm:mt-0") do
            #     whitespace
            #     input(
            #       name: "first-name",
            #       id: "first-name",
            #       autocomplete: "given-name",
            #       class:
            #         "block w-full rounded-md border-0 py-1.5 text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-indigo-600 sm:max-w-xs sm:text-sm sm:leading-6"
            #     )
            #   end
            # end
            # div(
            #   class: "sm:grid sm:grid-cols-3 sm:items-start sm:gap-4 sm:py-6"
            # ) do
            #   whitespace
            #   label(
            #     for: "last-name",
            #     class:
            #       "block text-sm font-medium leading-6 text-gray-900 sm:pt-1.5"
            #   ) { "Last name" }
            #   div(class: "mt-2 sm:col-span-2 sm:mt-0") do
            #     whitespace
            #     input(
            #       name: "last-name",
            #       id: "last-name",
            #       autocomplete: "family-name",
            #       class:
            #         "block w-full rounded-md border-0 py-1.5 text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-indigo-600 sm:max-w-xs sm:text-sm sm:leading-6"
            #     )
            #   end
            # end
            div(
              class: "sm:grid sm:grid-cols-3 sm:items-start sm:gap-4 sm:py-6"
            ) do
              whitespace
              label(
                for: "email",
                class:
                  "block text-sm font-medium leading-6 text-gray-900 sm:pt-1.5"
              ) { "Email address" }
              div(class: "mt-2 sm:col-span-2 sm:mt-0") do
                whitespace
                input(
                  id: "employee_email",
                  name: "employee[email]",
                  type: "email",
                  autocomplete: "email",
                  value: employee.email,
                  class:
                    "block w-full rounded-md border-0 py-1.5 text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-indigo-600 sm:max-w-md sm:text-sm sm:leading-6"
                )
              end
            end
            div(
              class: "sm:grid sm:grid-cols-3 sm:items-start sm:gap-4 sm:py-6"
            ) do
              whitespace
              label(
                for: "cell_phone",
                class:
                  "block text-sm font-medium leading-6 text-gray-900 sm:pt-1.5"
              ) { helpers.t("cell_phone") }
              div(class: "mt-2 sm:col-span-2 sm:mt-0") do
                whitespace
                input(
                  name: "employee[cell_phone]",
                  id: "employee_cell_phone",
                  autocomplete: "cell_phone",
                  value: employee.cell_phone,
                  class:
                    "block w-full rounded-md border-0 py-1.5 text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-indigo-600 sm:max-w-xl sm:text-sm sm:leading-6"
                )
              end
            end
            # div(
            #   class: "sm:grid sm:grid-cols-3 sm:items-start sm:gap-4 sm:py-6"
            # ) do
            #   whitespace
            #   label(
            #     for: "city",
            #     class:
            #       "block text-sm font-medium leading-6 text-gray-900 sm:pt-1.5"
            #   ) { "City" }
            #   div(class: "mt-2 sm:col-span-2 sm:mt-0") do
            #     whitespace
            #     input(
            #       name: "city",
            #       id: "city",
            #       autocomplete: "address-level2",
            #       class:
            #         "block w-full rounded-md border-0 py-1.5 text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-indigo-600 sm:max-w-xs sm:text-sm sm:leading-6"
            #     )
            #   end
            # end
            # div(
            #   class: "sm:grid sm:grid-cols-3 sm:items-start sm:gap-4 sm:py-6"
            # ) do
            #   whitespace
            #   label(
            #     for: "region",
            #     class:
            #       "block text-sm font-medium leading-6 text-gray-900 sm:pt-1.5"
            #   ) { "State / Province" }
            #   div(class: "mt-2 sm:col-span-2 sm:mt-0") do
            #     whitespace
            #     input(
            #       name: "region",
            #       id: "region",
            #       autocomplete: "address-level1",
            #       class:
            #         "block w-full rounded-md border-0 py-1.5 text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-indigo-600 sm:max-w-xs sm:text-sm sm:leading-6"
            #     )
            #   end
            # end
            # div(
            #   class: "sm:grid sm:grid-cols-3 sm:items-start sm:gap-4 sm:py-6"
            # ) do
            #   whitespace
            #   label(
            #     for: "postal-code",
            #     class:
            #       "block text-sm font-medium leading-6 text-gray-900 sm:pt-1.5"
            #   ) { "ZIP / Postal code" }
            #   div(class: "mt-2 sm:col-span-2 sm:mt-0") do
            #     whitespace
            #     input(
            #       name: "postal-code",
            #       id: "postal-code",
            #       autocomplete: "postal-code",
            #       class:
            #         "block w-full rounded-md border-0 py-1.5 text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-indigo-600 sm:max-w-xs sm:text-sm sm:leading-6"
            #     )
            #   end
            # end
          end
        end
        # div do
        #   h2(class: "text-base font-semibold leading-7 text-gray-900") do
        #     "Notifications"
        #   end
        #   p(class: "mt-1 max-w-2xl text-sm leading-6 text-gray-600") do
        #     "We'll always let you know about important changes, but you pick what else you want to hear about."
        #   end
        #   div(
        #     class:
        #       "mt-10 space-y-10 border-b border-gray-900/10 pb-12 sm:space-y-0 sm:divide-y sm:divide-gray-900/10 sm:border-t sm:pb-0"
        #   ) do
        #     fieldset do
        #       legend(class: "sr-only") { "By Email" }
        #       div(class: "sm:grid sm:grid-cols-3 sm:gap-4 sm:py-6") do
        #         div(
        #           class: "text-sm font-semibold leading-6 text-gray-900",
        #           aria_hidden: "true"
        #         ) { "By Email" }
        #         div(class: "mt-4 sm:col-span-2 sm:mt-0") do
        #           div(class: "max-w-lg space-y-6") do
        #             div(class: "relative flex gap-x-3") do
        #               div(class: "flex h-6 items-center") do
        #                 whitespace
        #                 input(
        #                   id: "comments",
        #                   name: "comments",
        #                   type: "checkbox",
        #                   class:
        #                     "h-4 w-4 rounded border-gray-300 text-indigo-600 focus:ring-indigo-600"
        #                 )
        #               end
        #               div(class: "text-sm leading-6") do
        #                 whitespace
        #                 label(
        #                   for: "comments",
        #                   class: "font-medium text-gray-900"
        #                 ) { "Comments" }
        #                 p(class: "mt-1 text-gray-600") do
        #                   "Get notified when someones posts a comment on a posting."
        #                 end
        #               end
        #             end
        #             div(class: "relative flex gap-x-3") do
        #               div(class: "flex h-6 items-center") do
        #                 whitespace
        #                 input(
        #                   id: "candidates",
        #                   name: "candidates",
        #                   type: "checkbox",
        #                   class:
        #                     "h-4 w-4 rounded border-gray-300 text-indigo-600 focus:ring-indigo-600"
        #                 )
        #               end
        #               div(class: "text-sm leading-6") do
        #                 whitespace
        #                 label(
        #                   for: "candidates",
        #                   class: "font-medium text-gray-900"
        #                 ) { "Candidates" }
        #                 p(class: "mt-1 text-gray-600") do
        #                   "Get notified when a candidate applies for a job."
        #                 end
        #               end
        #             end
        #             div(class: "relative flex gap-x-3") do
        #               div(class: "flex h-6 items-center") do
        #                 whitespace
        #                 input(
        #                   id: "offers",
        #                   name: "offers",
        #                   type: "checkbox",
        #                   class:
        #                     "h-4 w-4 rounded border-gray-300 text-indigo-600 focus:ring-indigo-600"
        #                 )
        #               end
        #               div(class: "text-sm leading-6") do
        #                 whitespace
        #                 label(
        #                   for: "offers",
        #                   class: "font-medium text-gray-900"
        #                 ) { "Offers" }
        #                 p(class: "mt-1 text-gray-600") do
        #                   "Get notified when a candidate accepts or rejects an offer."
        #                 end
        #               end
        #             end
        #           end
        #         end
        #       end
        #     end
        #     fieldset do
        #       legend(class: "sr-only") { "Push Notifications" }
        #       div(
        #         class:
        #           "sm:grid sm:grid-cols-3 sm:items-baseline sm:gap-4 sm:py-6"
        #       ) do
        #         div(
        #           class: "text-sm font-semibold leading-6 text-gray-900",
        #           aria_hidden: "true"
        #         ) { "Push Notifications" }
        #         div(class: "mt-1 sm:col-span-2 sm:mt-0") do
        #           div(class: "max-w-lg") do
        #             p(class: "text-sm leading-6 text-gray-600") do
        #               "These are delivered via SMS to your mobile phone."
        #             end
        #             div(class: "mt-6 space-y-6") do
        #               div(class: "flex items-center gap-x-3") do
        #                 whitespace
        #                 input(
        #                   id: "push-everything",
        #                   name: "push-notifications",
        #                   type: "radio",
        #                   class:
        #                     "h-4 w-4 border-gray-300 text-indigo-600 focus:ring-indigo-600"
        #                 )
        #                 whitespace
        #                 label(
        #                   for: "push-everything",
        #                   class:
        #                     "block text-sm font-medium leading-6 text-gray-900"
        #                 ) { "Everything" }
        #               end
        #               div(class: "flex items-center gap-x-3") do
        #                 whitespace
        #                 input(
        #                   id: "push-email",
        #                   name: "push-notifications",
        #                   type: "radio",
        #                   class:
        #                     "h-4 w-4 border-gray-300 text-indigo-600 focus:ring-indigo-600"
        #                 )
        #                 whitespace
        #                 label(
        #                   for: "push-email",
        #                   class:
        #                     "block text-sm font-medium leading-6 text-gray-900"
        #                 ) { "Same as email" }
        #               end
        #               div(class: "flex items-center gap-x-3") do
        #                 whitespace
        #                 input(
        #                   id: "push-nothing",
        #                   name: "push-notifications",
        #                   type: "radio",
        #                   class:
        #                     "h-4 w-4 border-gray-300 text-indigo-600 focus:ring-indigo-600"
        #                 )
        #                 whitespace
        #                 label(
        #                   for: "push-nothing",
        #                   class:
        #                     "block text-sm font-medium leading-6 text-gray-900"
        #                 ) { "No push notifications" }
        #               end
        #             end
        #           end
        #         end
        #       end
        #     end
        #   end
        # end
      end
      action_buttons
    end
  end

  def action_buttons
    div(class: "px-4 mt-6 mb-24 sm:mb-12 flex items-center justify-start gap-x-2") do
      whitespace
      button(
        type: "button",
        data: { action: "click->pos-employee#clearForm" },
        class: "mort-btn-cancel"
      ) { helpers.t("cancel") }
      whitespace
      button(
        type: "submit",
        class:
          "mort-btn-primary"
      ) { helpers.t("save") }
    end
  end
end

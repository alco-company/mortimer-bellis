class Settings::SettingsIndex < ApplicationComponent
  include Phlex::Rails::Helpers::TurboStreamFrom

  def initialize(form: nil, resources_stream: nil)
    @form = form
    @resources_stream = resources_stream || "settings:resources"
  end

  def view_template
    # List of settings for the organization, team, or user
    turbo_stream_from @resources_stream
    render partial: "header", locals: { batch_form: form }
    div(id: "list", role: "list", class: "") do
      div(class: "ml-6 mr-1") do
        div(class: "text-sm/6 pt-6") { "Settings for organization, team, or user - choose wisely in some situations" }
        dl(class: "divide-y divide-gray-100") do
          true_false "Create projects", "Allow Users to create projects on Time & Material registrations"
          edit_input "Monitor email address", "The email address used for monitoring", "margotfoster@example.com"
          div(class: "px-4 py-6 sm:grid sm:grid-cols-3 sm:gap-4 sm:px-0") do
            dt(class: "text-sm/6 font-medium text-gray-900") do
              "Max Invoice Amount"
            end
            dd(
              class: "mt-1 flex text-sm/6 text-gray-700 sm:col-span-2 sm:mt-0"
            ) do
              whitespace
              span(class: "grow") { "$120,000" }
              whitespace
              span(class: "ml-4 shrink-0") do
                whitespace
                button(
                  type: "button",
                  class:
                    "rounded-md bg-white font-medium text-indigo-600 hover:text-indigo-500"
                ) { "Edit" }
                whitespace
              end
            end
          end
          div(class: "px-4 py-6 sm:grid sm:grid-cols-3 sm:gap-4 sm:px-0") do
            dt(class: "text-sm/6 font-medium text-gray-900") do
              "Default Time/Material State"
            end
            dd(
              class: "mt-1 flex-col text-sm/6 text-gray-700 sm:col-span-2 sm:mt-0"
            ) do
              div do
                whitespace
                label(
                  for: "location",
                  class: "block text-sm/6 font-medium text-gray-900"
                ) { "State" }
                div(class: "mt-2 grid grid-cols-1") do
                  whitespace
                  select(
                    id: "location",
                    name: "location",
                    class:
                      "col-start-1 row-start-1 w-full appearance-none rounded-md bg-white py-1.5 pr-8 pl-3 text-base text-gray-900 outline-1 -outline-offset-1 outline-gray-300 focus:outline-2 focus:-outline-offset-2 focus:outline-indigo-600 sm:text-sm/6"
                  ) do
                    option(selected: "selected") { "Done" }
                    option { "Draft" }
                    option { "Parked" }
                    whitespace
                  end
                  whitespace
                  svg(
                    class:
                      "pointer-events-none col-start-1 row-start-1 mr-2 size-5 self-center justify-self-end text-gray-500 sm:size-4",
                    viewbox: "0 0 16 16",
                    fill: "currentColor",
                    aria_hidden: "true",
                    data_slot: "icon"
                  ) do |s|
                    s.path(
                      fill_rule: "evenodd",
                      d:
                        "M4.22 6.22a.75.75 0 0 1 1.06 0L8 8.94l2.72-2.72a.75.75 0 1 1 1.06 1.06l-3.25 3.25a.75.75 0 0 1-1.06 0L4.22 7.28a.75.75 0 0 1 0-1.06Z",
                      clip_rule: "evenodd"
                    )
                  end
                end
              end
              whitespace
              span(class: "grow") do
                "Opening a new Time Material item will set the state to the one selected here"
              end
              whitespace
              span(class: "ml-4 shrink-0") { whitespace }
            end
          end
          div(class: "px-4 py-6 sm:grid sm:grid-cols-3 sm:gap-4 sm:px-0") do
            dt(class: "text-sm/6 font-medium text-gray-900") { "Company Color" }
            dd(class: "mt-1 text-sm/6 text-gray-700 sm:col-span-2 sm:mt-0") do
              fieldset do
                legend(class: "block text-sm/6 font-semibold text-gray-900") do
                  "Choose a label color"
                end
                div(class: "mt-6 flex flex-wrap items-center gap-x-3 gap-y-2") do
                  # bg-red-500 bg-orange-500 bg-amber-500 bg-yellow-500 bg-lime-500 bg-green-500 bg-emerald-500 bg-teal-500 bg-cyan-500 bg-sky-500 bg-blue-500 bg-indigo-500 bg-violet-500 bg-purple-500 bg-fuchsia-500 bg-pink-500 bg-rose-500 bg-slate-500 bg-gray-500 bg-zinc-500 bg-neutral-500 bg-stone-500
                  %w[ red orange amber yellow lime green emerald teal cyan sky blue indigo violet purple fuchsia pink rose slate gray zinc neutral stone ].each do |color|
                    div(
                      class:
                        "flex rounded-full outline -outline-offset-1 outline-black/10"
                    ) do
                      whitespace
                      input(
                        aria_label: "#{color.capitalize}",
                        type: "radio",
                        name: "color-choice",
                        value: "#{color}",
                        class:
                          "size-8 appearance-none rounded-full bg-#{color}-500 forced-color-adjust-none checked:outline-2 checked:outline-offset-2 checked:outline-#{color}-500 focus-visible:outline-3 focus-visible:outline-offset-3"
                      )
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  def true_false(label, description, value = false)
    div(class: "px-4 py-6 sm:grid sm:grid-cols-3 sm:gap-4 sm:px-0") do
      dt(class: "text-sm/6 font-medium text-gray-900") { label }
      dd(
        class: "mt-1 flex text-sm/6 text-gray-700 sm:col-span-2 sm:mt-0"
      ) do
        span(class: "grow") do
          description
        end
        span(class: "ml-4 shrink-0") do
            render ToggleButton.new(resource: Setting.new,
            label: "toggle",
            value: value,
            url: nil,
            action: "click->boolean#toggle",
            attributes: {}
          )

          # button(
          #   type: "button",
          #   class:
          #     "group relative inline-flex h-5 w-10 shrink-0 cursor-pointer items-center justify-center rounded-full focus:ring-2 focus:ring-indigo-600 focus:ring-offset-2 focus:outline-hidden",
          #   role: "switch",
          #   aria_checked: "false"
          # ) do
          #   span(class: "sr-only") { "Use setting" }
          #   span(
          #     aria_hidden: "true",
          #     class:
          #       "pointer-events-none absolute size-full rounded-md bg-white"
          #   )
          #   comment do
          #     %(Enabled: "bg-indigo-600", Not Enabled: "bg-gray-200")
          #   end
          #   span(
          #     aria_hidden: "true",
          #     class:
          #       "pointer-events-none absolute mx-auto h-4 w-9 rounded-full bg-gray-200 transition-colors duration-200 ease-in-out"
          #   )
          #   comment do
          #     %(Enabled: "translate-x-5", Not Enabled: "translate-x-0")
          #   end
          #   span(
          #     aria_hidden: "true",
          #     class:
          #       "pointer-events-none absolute left-0 inline-block size-5 translate-x-0 transform rounded-full border border-gray-200 bg-white shadow-sm ring-0 transition-transform duration-200 ease-in-out"
          #   )
          # end
        end
      end
    end
  end

  def edit_input(label, description, value)
    div(class: "px-4 py-6 sm:grid sm:grid-cols-3 sm:gap-4 sm:px-0") do
      dt(class: "text-sm/6 font-medium text-gray-900") do
        label
      end
      dd(
        class: "mt-1 flex text-sm/6 text-gray-700 sm:col-span-2 sm:mt-0"
      ) do
        div(class: "flex flex-col grow") do
          span(class: "grow") { value }
          span(class: "text-sm/6 text-gray-500") { description }
        end
        span(class: "ml-4 shrink-0") do
          button(
            type: "button",
            class:
              "rounded-md bg-white font-medium text-indigo-600 hover:text-indigo-500"
          ) { "Edit" }
        end
      end
    end
  end
end

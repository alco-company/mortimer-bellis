class TimeMaterialForm < Phlex::HTML
  def view_template
    div(class: "relative flex min-h-screen flex-col overflow-hidden mx-auto max-w-lg lg:w-1/2 xl:w-1/3 lg:mx-0 lg:float-right py-6 sm:py-12") do
      div(class: "relative bg-white px-6 pb-8 pt-10 ring-1 ring-gray-900/5 sm:rounded-lg sm:px-2", data: { controller: "tabs", tabs_index: "0" }) do
        div(class: "mx-auto max-w-full") do
          div do
            div(class: "") do
              div(class: "border-b border-gray-200") do
                nav(class: "-mb-px flex space-x-8", aria_label: "Tabs") do
                  time_tab
                  material_tab
                end
              end
            end
          end
          show_time_tab
          show_material_tab
        end
      end
    end
  end

  def time_tab
    # comment do
    #   %(Current: "border-indigo-500 text-indigo-600", Default: "border-transparent text-gray-500 hover:border-gray-300 hover:text-gray-700")
    # end
    button(
      type: "button",
      data: { tabs_target: "tab", action: "tabs#change" },
      value: 0,
      class: "flex justify-center tab-header w-1/2 border-b-2 border-transparent px-1 py-4 text-center text-sm font-medium text-gray-500 hover:border-gray-300 hover:text-gray-700",
      role: "switch",
      aria_checked: "false") do
        # comment do
        #   %(Current: "text-indigo-500", Default: "text-gray-400 group-hover:text-gray-500")
        # end
        svg(
          class:
            "-ml-0.5 mr-2 h-5 w-5 text-indigo-500 group-hover:text-indigo-500",
          viewbox: "0 0 20 20",
          fill: "currentColor",
          aria_hidden: "true",
          data_slot: "icon"
        ) do |s|
          s.path(
            d:
              "M10 8a3 3 0 1 0 0-6 3 3 0 0 0 0 6ZM3.465 14.493a1.23 1.23 0 0 0 .41 1.412A9.957 9.957 0 0 0 10 18c2.31 0 4.438-.784 6.131-2.1.43-.333.604-.903.408-1.41a7.002 7.002 0 0 0-13.074.003Z"
          )
        end
        span { I18n.t("time_material.type.time") }
    end
  end

  def material_tab
    # comment do
    #   %(Current: "border-indigo-500 text-indigo-600", Default: "border-transparent text-gray-500 hover:border-gray-300 hover:text-gray-700")
    # end
    button(
      type: "button",
      data: { tabs_target: "tab", action: "tabs#change" },
      value: 1,
      class: "flex justify-center tab-header w-1/2 border-b-2 border-transparent px-1 py-4 text-center text-sm font-medium text-gray-500 hover:border-gray-300 hover:text-gray-700",
      role: "switch",
      aria_checked: "false") do
        # comment do
        #   %(Current: "text-indigo-500", Default: "text-gray-400 group-hover:text-gray-500")
        # end
        svg(
          class:
            "-ml-0.5 mr-2 h-5 w-5 text-gray-400 group-hover:text-gray-500",
          viewbox: "0 0 20 20",
          fill: "currentColor",
          aria_hidden: "true",
          data_slot: "icon"
        ) do |s|
          s.path(
            fill_rule: "evenodd",
            d:
              "M4 16.5v-13h-.25a.75.75 0 0 1 0-1.5h12.5a.75.75 0 0 1 0 1.5H16v13h.25a.75.75 0 0 1 0 1.5h-3.5a.75.75 0 0 1-.75-.75v-2.5a.75.75 0 0 0-.75-.75h-2.5a.75.75 0 0 0-.75.75v2.5a.75.75 0 0 1-.75.75h-3.5a.75.75 0 0 1 0-1.5H4Zm3-11a.5.5 0 0 1 .5-.5h1a.5.5 0 0 1 .5.5v1a.5.5 0 0 1-.5.5h-1a.5.5 0 0 1-.5-.5v-1ZM7.5 9a.5.5 0 0 0-.5.5v1a.5.5 0 0 0 .5.5h1a.5.5 0 0 0 .5-.5v-1a.5.5 0 0 0-.5-.5h-1ZM11 5.5a.5.5 0 0 1 .5-.5h1a.5.5 0 0 1 .5.5v1a.5.5 0 0 1-.5.5h-1a.5.5 0 0 1-.5-.5v-1Zm.5 3.5a.5.5 0 0 0-.5.5v1a.5.5 0 0 0 .5.5h1a.5.5 0 0 0 .5-.5v-1a.5.5 0 0 0-.5-.5h-1Z",
            clip_rule: "evenodd"
          )
        end
        span { I18n.t("time_material.type.material") }
    end
  end


  def show_time_tab
    div(id: "time", data: { tabs_target: "tabPanel" }, class: "time-material-type time tab ") do
      form do
        div(class: "space-y-12") do
          div(class: "border-b border-gray-900/10 pb-12") do
            div(
              class: "mt-10 grid grid-cols-1 gap-x-6 gap-y-8 sm:grid-cols-6"
            ) do
              div(class: "sm:col-span-4") do
                whitespace
                label(
                  for: "username",
                  class: "block text-sm font-medium leading-6 text-gray-900"
                ) { "Dato" }
                div(class: "mt-2") do
                  div(
                    class:
                      "flex rounded-md shadow-sm ring-1 ring-inset ring-gray-300 focus-within:ring-2 focus-within:ring-inset focus-within:ring-indigo-600 sm:max-w-md"
                  ) do
                    whitespace
                    input(
                      type: "date",
                      name: "username",
                      id: "username",
                      class:
                        "block flex-1 border-0 bg-transparent py-1.5 pl-2 text-gray-900 placeholder:text-gray-400 focus:ring-0 sm:text-sm sm:leading-6"
                    )
                  end
                end
              end
              div(class: "sm:col-span-4") do
                whitespace
                label(
                  for: "username",
                  class: "block text-sm font-medium leading-6 text-gray-900"
                ) { "Tidsforbrug" }
                div(class: "mt-2") do
                  div(
                    class:
                      "flex rounded-md shadow-sm ring-1 ring-inset ring-gray-300 focus-within:ring-2 focus-within:ring-inset focus-within:ring-indigo-600 sm:max-w-md"
                  ) do
                    whitespace
                    input(
                      name: "username",
                      id: "username",
                      class:
                        "block flex-1 border-0 bg-transparent py-1.5 pl-2 text-gray-900 placeholder:text-gray-400 focus:ring-0 sm:text-sm sm:leading-6",
                      placeholder: "1,25 or 1.15 or 10:00-11:15"
                    )
                  end
                end
              end
              div(class: "col-span-full") do
                whitespace
                label(
                  for: "about",
                  class: "block text-sm font-medium leading-6 text-gray-900"
                ) { "About" }
                div(class: "mt-2") do
                  whitespace
                  textarea(
                    id: "about",
                    name: "about",
                    rows: "3",
                    class:
                      "block w-full rounded-md border-0 py-1.5 px-2.5 text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-indigo-600 sm:text-sm sm:leading-6",
                    placeholder: "what did you do?"
                  )
                end
                p(class: "mt-3 text-sm leading-6 text-gray-600") do
                  "Write a few sentences about yourself."
                end
              end
              div(class: "sm:col-span-4") do
                whitespace
                label(
                  for: "username",
                  class: "block text-sm font-medium leading-6 text-gray-900"
                ) { "Kunde" }
                div(class: "mt-2") do
                  div(
                    class:
                      "flex rounded-md shadow-sm ring-1 ring-inset ring-gray-300 focus-within:ring-2 focus-within:ring-inset focus-within:ring-indigo-600 sm:max-w-md"
                  ) do
                    whitespace
                    input(
                      name: "username",
                      id: "username",
                      autocomplete: "username",
                      class:
                        "block flex-1 border-0 bg-transparent py-1.5 pl-2 text-gray-900 placeholder:text-gray-400 focus:ring-0 sm:text-sm sm:leading-6",
                      placeholder: "janesmith"
                    )
                  end
                end
              end
              div(class: "sm:col-span-4") do
                whitespace
                label(
                  for: "username",
                  class: "block text-sm font-medium leading-6 text-gray-900"
                ) { "Projekt" }
                div(class: "mt-2") do
                  div(
                    class:
                      "flex rounded-md shadow-sm ring-1 ring-inset ring-gray-300 focus-within:ring-2 focus-within:ring-inset focus-within:ring-indigo-600 sm:max-w-md"
                  ) do
                    whitespace
                    input(
                      name: "username",
                      id: "username",
                      autocomplete: "username",
                      class:
                        "block flex-1 border-0 bg-transparent py-1.5 pl-2 text-gray-900 placeholder:text-gray-400 focus:ring-0 sm:text-sm sm:leading-6",
                      placeholder: "janesmith"
                    )
                  end
                end
              end
              div(class: "sm:col-span-4") do
                whitespace
                label(
                  for: "username",
                  class: "block text-sm font-medium leading-6 text-gray-900"
                ) { "Timepris" }
                div(class: "mt-2") do
                  div(
                    class:
                      "flex rounded-md shadow-sm ring-1 ring-inset ring-gray-300 focus-within:ring-2 focus-within:ring-inset focus-within:ring-indigo-600 sm:max-w-md"
                  ) do
                    whitespace
                    input(
                      name: "username",
                      id: "username",
                      class:
                        "block flex-1 border-0 bg-transparent py-1.5 pl-2 text-gray-900 placeholder:text-gray-400 focus:ring-0 sm:text-sm sm:leading-6",
                      placeholder: "900"
                    )
                  end
                end
              end
            end
          end
          div(class: "border-b border-gray-900/10 pb-12") do
            div(class: "mt-10 space-y-10") do
              fieldset do
                legend(
                  class: "text-sm font-semibold leading-6 text-gray-900"
                ) { "Fakturering" }
                div(class: "mt-6 space-y-6") do
                  div(class: "relative flex gap-x-3") do
                    div(class: "flex h-6 items-center") do
                      whitespace
                      input(
                        id: "comments",
                        name: "comments",
                        type: "checkbox",
                        class:
                          "h-4 w-4 rounded border-gray-300 text-indigo-600 focus:ring-indigo-600"
                      )
                    end
                    div(class: "text-sm leading-6") do
                      whitespace
                      label(
                        for: "comments",
                        class: "font-medium text-gray-900"
                      ) { "skal faktureres" }
                      p(class: "text-gray-500") { "Ydelsen er fakturérbar" }
                    end
                  end
                  div(class: "relative flex gap-x-3") do
                    div(class: "flex h-6 items-center") do
                      whitespace
                      input(
                        id: "candidates",
                        name: "candidates",
                        type: "checkbox",
                        class:
                          "h-4 w-4 rounded border-gray-300 text-indigo-600 focus:ring-indigo-600"
                      )
                    end
                    div(class: "text-sm leading-6") do
                      whitespace
                      label(
                        for: "candidates",
                        class: "font-medium text-gray-900"
                      ) { "per kulance" }
                      p(class: "text-gray-500") do
                        "sættes på faktura med 100% rabat"
                      end
                    end
                  end
                  div(class: "relative flex gap-x-3") do
                    div(class: "flex h-6 items-center") do
                      whitespace
                      input(
                        id: "offers",
                        name: "offers",
                        type: "checkbox",
                        disabled: "disabled",
                        class:
                          "h-4 w-4 rounded border-gray-300 text-indigo-600 focus:ring-indigo-600"
                      )
                    end
                    div(class: "text-sm leading-6") do
                      whitespace
                      label(
                        for: "offers",
                        class: "font-medium text-gray-900"
                      ) { "Tilbud" }
                      p(class: "text-gray-500") do
                        "Opret et tilbud til kunden"
                      end
                    end
                  end
                end
              end
              fieldset do
                legend(
                  class: "text-sm font-semibold leading-6 text-gray-900"
                ) { "Samlefakturering" }
                div(class: "mt-6 space-y-6") do
                  div(class: "relative flex gap-x-3") do
                    div(class: "flex h-6 items-center") do
                      whitespace
                      input(
                        id: "offers",
                        name: "offers",
                        type: "checkbox",
                        class:
                          "h-4 w-4 rounded border-gray-300 text-indigo-600 focus:ring-indigo-600"
                      )
                    end
                    div(class: "text-sm leading-6") do
                      whitespace
                      label(
                        for: "offers",
                        class: "font-medium text-gray-900"
                      ) { "Tilbud" }
                      p(class: "text-gray-500") do
                        "Opret en særskilt faktura"
                      end
                    end
                  end
                end
              end
            end
          end
        end
        div(class: "mt-6 flex items-center justify-end gap-x-6") do
          whitespace
          button(
            type: "button",
            class: "text-sm font-semibold leading-6 text-gray-900"
          ) { "Fortryd" }
          whitespace
          button(
            type: "submit",
            class:
              "rounded-md bg-indigo-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-indigo-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600"
          ) { "Gem" }
        end
      end
    end
  end

  def show_material_tab
    div(id: "material", data: { tabs_target: "tabPanel" }, class: "time-material-type material tab hidden") do
      form do
        div(class: "space-y-12") do
          div(class: "border-b border-gray-900/10 pb-12") do
            div(
              class: "mt-10 grid grid-cols-1 gap-x-6 gap-y-8 sm:grid-cols-6"
            ) do
              div(class: "sm:col-span-4") do
                whitespace
                label(
                  for: "username",
                  class: "block text-sm font-medium leading-6 text-gray-900"
                ) { "Produkt" }
                div(class: "mt-2") do
                  div(
                    class:
                      "flex rounded-md shadow-sm ring-1 ring-inset ring-gray-300 focus-within:ring-2 focus-within:ring-inset focus-within:ring-indigo-600 sm:max-w-md"
                  ) do
                    whitespace
                    input(
                      name: "username",
                      id: "username",
                      class:
                        "block flex-1 border-0 bg-transparent py-1.5 pl-2 text-gray-900 placeholder:text-gray-400 focus:ring-0 sm:text-sm sm:leading-6",
                      placeholder: "1,25 or 1.15 or 10:00-11:15"
                    )
                  end
                end
              end
              div(class: "col-span-full") do
                whitespace
                label(
                  for: "about",
                  class: "block text-sm font-medium leading-6 text-gray-900"
                ) { "About" }
                div(class: "mt-2") do
                  whitespace
                  textarea(
                    id: "about",
                    name: "about",
                    rows: "3",
                    class:
                      "block w-full rounded-md border-0 py-1.5 px-2.5 text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-indigo-600 sm:text-sm sm:leading-6",
                    placeholder: "what did you do?"
                  )
                end
                p(class: "mt-3 text-sm leading-6 text-gray-600") do
                  "Write a few sentences about yourself."
                end
              end
              div(class: "sm:col-span-4") do
                whitespace
                label(
                  for: "username",
                  class: "block text-sm font-medium leading-6 text-gray-900"
                ) { "Kunde" }
                div(class: "mt-2") do
                  div(
                    class:
                      "flex rounded-md shadow-sm ring-1 ring-inset ring-gray-300 focus-within:ring-2 focus-within:ring-inset focus-within:ring-indigo-600 sm:max-w-md"
                  ) do
                    whitespace
                    input(
                      name: "username",
                      id: "username",
                      autocomplete: "username",
                      class:
                        "block flex-1 border-0 bg-transparent py-1.5 pl-2 text-gray-900 placeholder:text-gray-400 focus:ring-0 sm:text-sm sm:leading-6",
                      placeholder: "janesmith"
                    )
                  end
                end
              end
              div(class: "sm:col-span-4") do
                whitespace
                label(
                  for: "username",
                  class: "block text-sm font-medium leading-6 text-gray-900"
                ) { "Projekt" }
                div(class: "mt-2") do
                  div(
                    class:
                      "flex rounded-md shadow-sm ring-1 ring-inset ring-gray-300 focus-within:ring-2 focus-within:ring-inset focus-within:ring-indigo-600 sm:max-w-md"
                  ) do
                    whitespace
                    input(
                      name: "username",
                      id: "username",
                      autocomplete: "username",
                      class:
                        "block flex-1 border-0 bg-transparent py-1.5 pl-2 text-gray-900 placeholder:text-gray-400 focus:ring-0 sm:text-sm sm:leading-6",
                      placeholder: "janesmith"
                    )
                  end
                end
              end
              div(class: "sm:col-span-4") do
                whitespace
                label(
                  for: "username",
                  class: "block text-sm font-medium leading-6 text-gray-900"
                ) { "Antal" }
                div(class: "mt-2") do
                  div(
                    class:
                      "flex rounded-md shadow-sm ring-1 ring-inset ring-gray-300 focus-within:ring-2 focus-within:ring-inset focus-within:ring-indigo-600 sm:max-w-md"
                  ) do
                    whitespace
                    input(
                      name: "username",
                      id: "username",
                      class:
                        "block flex-1 border-0 bg-transparent py-1.5 pl-2 text-gray-900 placeholder:text-gray-400 focus:ring-0 sm:text-sm sm:leading-6",
                      placeholder: "900"
                    )
                  end
                end
              end
              div(class: "sm:col-span-4") do
                whitespace
                label(
                  for: "username",
                  class: "block text-sm font-medium leading-6 text-gray-900"
                ) { "Stk pris" }
                div(class: "mt-2") do
                  div(
                    class:
                      "flex rounded-md shadow-sm ring-1 ring-inset ring-gray-300 focus-within:ring-2 focus-within:ring-inset focus-within:ring-indigo-600 sm:max-w-md"
                  ) do
                    whitespace
                    input(
                      name: "username",
                      id: "username",
                      class:
                        "block flex-1 border-0 bg-transparent py-1.5 pl-2 text-gray-900 placeholder:text-gray-400 focus:ring-0 sm:text-sm sm:leading-6",
                      placeholder: "900"
                    )
                  end
                end
              end
              div(class: "sm:col-span-4") do
                whitespace
                label(
                  for: "username",
                  class: "block text-sm font-medium leading-6 text-gray-900"
                ) { "Rabat" }
                div(class: "mt-2") do
                  div(
                    class:
                      "flex rounded-md shadow-sm ring-1 ring-inset ring-gray-300 focus-within:ring-2 focus-within:ring-inset focus-within:ring-indigo-600 sm:max-w-md"
                  ) do
                    whitespace
                    input(
                      name: "username",
                      id: "username",
                      class:
                        "block flex-1 border-0 bg-transparent py-1.5 pl-2 text-gray-900 placeholder:text-gray-400 focus:ring-0 sm:text-sm sm:leading-6",
                      placeholder: "900"
                    )
                  end
                end
              end
            end
          end
          div(class: "border-b border-gray-900/10 pb-12") do
            div(class: "mt-10 space-y-10") do
              fieldset do
                legend(
                  class: "text-sm font-semibold leading-6 text-gray-900"
                ) { "Fakturering" }
                div(class: "mt-6 space-y-6") do
                  div(class: "relative flex gap-x-3") do
                    div(class: "flex h-6 items-center") do
                      whitespace
                      input(
                        id: "comments",
                        name: "comments",
                        type: "checkbox",
                        class:
                          "h-4 w-4 rounded border-gray-300 text-indigo-600 focus:ring-indigo-600"
                      )
                    end
                    div(class: "text-sm leading-6") do
                      whitespace
                      label(
                        for: "comments",
                        class: "font-medium text-gray-900"
                      ) { "skal faktureres" }
                      p(class: "text-gray-500") { "Ydelsen er fakturérbar" }
                    end
                  end
                  div(class: "relative flex gap-x-3") do
                    div(class: "flex h-6 items-center") do
                      whitespace
                      input(
                        id: "candidates",
                        name: "candidates",
                        type: "checkbox",
                        class:
                          "h-4 w-4 rounded border-gray-300 text-indigo-600 focus:ring-indigo-600"
                      )
                    end
                    div(class: "text-sm leading-6") do
                      whitespace
                      label(
                        for: "candidates",
                        class: "font-medium text-gray-900"
                      ) { "per kulance" }
                      p(class: "text-gray-500") do
                        "sættes på faktura med 100% rabat"
                      end
                    end
                  end
                  div(class: "relative flex gap-x-3") do
                    div(class: "flex h-6 items-center") do
                      whitespace
                      input(
                        id: "offers",
                        name: "offers",
                        type: "checkbox",
                        disabled: "disabled",
                        class:
                          "h-4 w-4 rounded border-gray-300 text-indigo-600 focus:ring-indigo-600"
                      )
                    end
                    div(class: "text-sm leading-6") do
                      whitespace
                      label(
                        for: "offers",
                        class: "font-medium text-gray-900"
                      ) { "Tilbud" }
                      p(class: "text-gray-500") do
                        "Opret et tilbud til kunden"
                      end
                    end
                  end
                end
              end
              fieldset do
                legend(
                  class: "text-sm font-semibold leading-6 text-gray-900"
                ) { "Samlefakturering" }
                div(class: "mt-6 space-y-6") do
                  div(class: "relative flex gap-x-3") do
                    div(class: "flex h-6 items-center") do
                      whitespace
                      input(
                        id: "offers",
                        name: "offers",
                        type: "checkbox",
                        class:
                          "h-4 w-4 rounded border-gray-300 text-indigo-600 focus:ring-indigo-600"
                      )
                    end
                    div(class: "text-sm leading-6") do
                      whitespace
                      label(
                        for: "offers",
                        class: "font-medium text-gray-900"
                      ) { "Tilbud" }
                      p(class: "text-gray-500") do
                        "Opret en særskilt faktura"
                      end
                    end
                  end
                end
              end
            end
          end
        end
        div(class: "mt-6 flex items-center justify-end gap-x-6") do
          whitespace
          button(
            type: "button",
            class: "text-sm font-semibold leading-6 text-gray-900"
          ) { "Fortryd" }
          whitespace
          button(
            type: "submit",
            class:
              "rounded-md bg-indigo-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-indigo-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600"
          ) { "Gem" }
        end
      end
    end
  end
end

class EventsList < ApplicationComponent
  attr_reader :request, :platform

  def initialize(&block)
  end

  def view_template(&block)
    ul(class: "space-y-4") do
      holidays
      punch_list
      event_list
    end
  end

  #
  # holidays, more
  def holidays
    li(class: "flex items-center p-1") do
      div(class: "flex flex-col flex-grow truncate") do
        div(class: "text-xs text-violet-600 font-thin flex justify-start items-center") do
          svg(
            class: "pr-1 text-violet-600",
            xmlns: "http://www.w3.org/2000/svg",
            height: "24px",
            viewbox: "0 -960 960 960",
            width: "24px",
            fill: "currentColor"
          ) do |s|
            s.path(
              d:
                "m80-80 200-560 360 360L80-80Zm132-132 282-100-182-182-100 282Zm370-246-42-42 224-224q32-32 77-32t77 32l24 24-42 42-24-24q-14-14-35-14t-35 14L582-458ZM422-618l-42-42 24-24q14-14 14-34t-14-34l-26-26 42-42 26 26q32 32 32 76t-32 76l-24 24Zm80 80-42-42 144-144q14-14 14-35t-14-35l-64-64 42-42 64 64q32 32 32 77t-32 77L502-538Zm160 160-42-42 64-64q32-32 77-32t77 32l64 64-42 42-64-64q-14-14-35-14t-35 14l-64 64ZM212-212Z"
            )
          end
          div(class: "pr-1") { "helligdag" }
          div(class: "pr-1") { "fredag" }
          div(class: "pr-1") { "uge 26" }
          div(class: "pr-1") { "5. maj" }
          div(class: "pr-1") { "1945" }
        end
        div(class: "grid grid-flow-col") do
          p(class: "truncate") { "Danmarks befrielse" }
        end
      end
      div(class: "flex-grow-0") do
        svg(
          class: "text-gray-300",
          xmlns: "http://www.w3.org/2000/svg",
          height: "24px",
          viewbox: "0 -960 960 960",
          width: "24px",
          fill: "currentColor"
        ) do |s|
          s.path(
            d:
              "M480-160q-33 0-56.5-23.5T400-240q0-33 23.5-56.5T480-320q33 0 56.5 23.5T560-240q0 33-23.5 56.5T480-160Zm0-240q-33 0-56.5-23.5T400-480q0-33 23.5-56.5T480-560q33 0 56.5 23.5T560-480q0 33-23.5 56.5T480-400Zm0-240q-33 0-56.5-23.5T400-720q0-33 23.5-56.5T480-800q33 0 56.5 23.5T560-720q0 33-23.5 56.5T480-640Z"
          )
        end
      end
    end
  end

  #
  # punches from the punch_card
  def punch_list
    li(class: "flex items-center p-1") do
      div(class: "flex flex-col flex-grow truncate") do
        div(
          class: "text-xs font-thin flex justify-start items-center"
        ) do
          whitespace
          svg(
            class: "pr-1 text-sky-600",
            xmlns: "http://www.w3.org/2000/svg",
            height: "24px",
            viewbox: "0 -960 960 960",
            width: "24px",
            fill: "currentColor"
          ) do |s|
            s.path(
              d:
                "M200-80q-33 0-56.5-23.5T120-160v-480q0-33 23.5-56.5T200-720h40v-200h480v200h40q33 0 56.5 23.5T840-640v480q0 33-23.5 56.5T760-80H200Zm120-640h320v-120H320v120ZM200-160h560v-480H200v480Zm280-40q83 0 141.5-58.5T680-400q0-83-58.5-141.5T480-600q-83 0-141.5 58.5T280-400q0 83 58.5 141.5T480-200Zm0-60q-58 0-99-41t-41-99q0-58 41-99t99-41q58 0 99 41t41 99q0 58-41 99t-99 41Zm46-66 28-28-54-54v-92h-40v108l66 66Zm-46-74Z"
            )
          end
          div(class: "pr-1 text-sky-600 font-mono") { "stemplinger" }
          div(class: "pr-1") { "torsdag" }
          div(class: "pr-1") { "uge 30" }
          div(class: "pr-1") { "20. september" }
          div(class: "pr-1") { "2024" }
        end
        ul(class: "text-xs space-y-1") do
          li(class: "grid grid-cols-6 gap-x-1") do
            div(class: "place-self-end font-mono") { "7:05" }
            div { "arbejde" }
            div(class: "col-span-3 truncate") do
              "mødte tidligt - men glemte alt om julen"
            end
          end
          li(class: "grid grid-cols-6 gap-x-1") do
            div(class: "place-self-end font-mono") { "7:05" }
            div { "pause" }
            div(class: "col-span-3 truncate") { "mødte tidligt" }
          end
          li(class: "grid grid-cols-6 gap-x-1") do
            div(class: "place-self-end font-mono") { "7:05" }
            div(class: "truncate") { "bediningun" }
            div(class: "col-span-3 truncate") { "mødte tidligt" }
          end
        end
      end
      div(class: "flex-grow-0") do
        whitespace
        svg(
          class: "text-gray-300",
          xmlns: "http://www.w3.org/2000/svg",
          height: "24px",
          viewbox: "0 -960 960 960",
          width: "24px",
          fill: "currentColor"
        ) do |s|
          s.path(
            d:
              "M480-160q-33 0-56.5-23.5T400-240q0-33 23.5-56.5T480-320q33 0 56.5 23.5T560-240q0 33-23.5 56.5T480-160Zm0-240q-33 0-56.5-23.5T400-480q0-33 23.5-56.5T480-560q33 0 56.5 23.5T560-480q0 33-23.5 56.5T480-400Zm0-240q-33 0-56.5-23.5T400-720q0-33 23.5-56.5T480-800q33 0 56.5 23.5T560-720q0 33-23.5 56.5T480-640Z"
          )
        end
      end
    end
  end

  #
  # hele dagen
  def event_list
    li(class: "flex items-center p-1") do
      div(class: "flex flex-col flex-grow truncate") do
        div(class: "text-xs font-thin") do
          whitespace
          span(class: "text-amber-500") { "hele dagen" }
          whitespace
          span { "torsdag" }
          whitespace
          span { "uge 30" }
          whitespace
          span { "20. september asd asd " }
          whitespace
          span { "2024" }
        end
        div(class: "grid grid-flow-col") do
          p(class: "truncate") do
            "Klippe hæk - men herefter kommer der en kæmpelang beskrivelse, og den bliver bare ved og ved"
          end
        end
      end
      div(class: "") do
        whitespace
        svg(
          class: "text-gray-300",
          xmlns: "http://www.w3.org/2000/svg",
          height: "24px",
          viewbox: "0 -960 960 960",
          width: "24px",
          fill: "currentColor"
        ) do |s|
          s.path(
            d:
              "M480-160q-33 0-56.5-23.5T400-240q0-33 23.5-56.5T480-320q33 0 56.5 23.5T560-240q0 33-23.5 56.5T480-160Zm0-240q-33 0-56.5-23.5T400-480q0-33 23.5-56.5T480-560q33 0 56.5 23.5T560-480q0 33-23.5 56.5T480-400Zm0-240q-33 0-56.5-23.5T400-720q0-33 23.5-56.5T480-800q33 0 56.5 23.5T560-720q0 33-23.5 56.5T480-640Z"
          )
        end
      end
    end
    whitespace
    # almindelig m/kort tekst
    li(class: "flex items-center bg-yellow-200 p-1") do
      div(class: "flex flex-col flex-grow truncate") do
        div(class: "text-xs font-thin") do
          whitespace
          span { "08.00 - 14:45" }
          whitespace
          span { "torsdag" }
          whitespace
          span { "uge 30" }
          whitespace
          span { "20. september" }
          whitespace
          span { "2024" }
        end
        div(class: "grid grid-flow-col") do
          p(class: "truncate") { "Klippe hæk" }
        end
      end
      div(class: "flex-grow-0") do
        div do
          whitespace
          svg(
            class: "text-gray-300",
            xmlns: "http://www.w3.org/2000/svg",
            height: "24px",
            viewbox: "0 -960 960 960",
            width: "24px",
            fill: "currentColor"
          ) do |s|
            s.path(
              d:
                "M480-160q-33 0-56.5-23.5T400-240q0-33 23.5-56.5T480-320q33 0 56.5 23.5T560-240q0 33-23.5 56.5T480-160Zm0-240q-33 0-56.5-23.5T400-480q0-33 23.5-56.5T480-560q33 0 56.5 23.5T560-480q0 33-23.5 56.5T480-400Zm0-240q-33 0-56.5-23.5T400-720q0-33 23.5-56.5T480-800q33 0 56.5 23.5T560-720q0 33-23.5 56.5T480-640Z"
            )
          end
        end
      end
    end
    whitespace
    # lang tekst + attention på more
    li(class: "flex items-center p-1") do
      div(class: "flex flex-col flex-grow truncate") do
        div(class: "text-xs font-thin") do
          whitespace
          span { "08.00 - 14:45" }
          whitespace
          span { "torsdag" }
          whitespace
          span { "uge 30" }
          whitespace
          span { "20. september" }
          whitespace
          span { "2024" }
        end
        div(class: "grid grid-flow-col") do
          p(class: "truncate") do
            "Klippe hæk - men herefter kommer der en kæmpelang beskrivelse"
          end
        end
      end
      div(class: "") do
        whitespace
        svg(
          class: "text-pink-500",
          xmlns: "http://www.w3.org/2000/svg",
          height: "24px",
          viewbox: "0 -960 960 960",
          width: "24px",
          fill: "currentColor"
        ) do |s|
          s.path(
            d:
              "M480-160q-33 0-56.5-23.5T400-240q0-33 23.5-56.5T480-320q33 0 56.5 23.5T560-240q0 33-23.5 56.5T480-160Zm0-240q-33 0-56.5-23.5T400-480q0-33 23.5-56.5T480-560q33 0 56.5 23.5T560-480q0 33-23.5 56.5T480-400Zm0-240q-33 0-56.5-23.5T400-720q0-33 23.5-56.5T480-800q33 0 56.5 23.5T560-720q0 33-23.5 56.5T480-640Z"
          )
        end
      end
    end
    whitespace
    # attention på hele opgaven
    li(class: "flex items-center border-l border-red-400 p-1 pl-3") do
      div(class: "flex flex-col flex-grow truncate") do
        div(class: "text-xs font-thin") do
          whitespace
          span { "08.00 - 14:45" }
          whitespace
          span { "torsdag" }
          whitespace
          span { "uge 30" }
          whitespace
          span { "20. september" }
          whitespace
          span { "2024" }
        end
        div(class: "grid grid-flow-col") do
          p(class: "truncate") do
            "Klippe hæk - men herefter kommer der en kæmpelang beskrivelse"
          end
        end
      end
      div do
        whitespace
        svg(
          class: "text-gray-300",
          xmlns: "http://www.w3.org/2000/svg",
          height: "24px",
          viewbox: "0 -960 960 960",
          width: "24px",
          fill: "currentColor"
        ) do |s|
          s.path(
            d:
              "M480-160q-33 0-56.5-23.5T400-240q0-33 23.5-56.5T480-320q33 0 56.5 23.5T560-240q0 33-23.5 56.5T480-160Zm0-240q-33 0-56.5-23.5T400-480q0-33 23.5-56.5T480-560q33 0 56.5 23.5T560-480q0 33-23.5 56.5T480-400Zm0-240q-33 0-56.5-23.5T400-720q0-33 23.5-56.5T480-800q33 0 56.5 23.5T560-720q0 33-23.5 56.5T480-640Z"
          )
        end
      end
    end
    whitespace
    # recurring event
    li(class: "flex items-center p-1") do
      div(class: "flex flex-col flex-grow truncate") do
        div(
          class:
            "grid grid-flow-col items-center justify-start text-xs font-thin"
        ) do
          whitespace
          svg(
            class: "pr-1 text-sky-400",
            xmlns: "http://www.w3.org/2000/svg",
            height: "24px",
            viewbox: "0 -960 960 960",
            width: "24px",
            fill: "currentColor"
          ) do |s|
            s.path(
              d:
                "M200-80q-33 0-56.5-23.5T120-160v-560q0-33 23.5-56.5T200-800h40v-80h80v80h320v-80h80v80h40q33 0 56.5 23.5T840-720v240h-80v-80H200v400h280v80H200ZM760 0q-73 0-127.5-45.5T564-160h62q13 44 49.5 72T760-60q58 0 99-41t41-99q0-58-41-99t-99-41q-29 0-54 10.5T662-300h58v60H560v-160h60v57q27-26 63-41.5t77-15.5q83 0 141.5 58.5T960-200q0 83-58.5 141.5T760 0ZM200-640h560v-80H200v80Zm0 0v-80 80Z"
            )
          end
          whitespace
          span(class: "pr-1") { "08.00 - 14:45" }
          whitespace
          span(class: "pr-1 text-sky-400 font-bold") { "torsdag" }
          whitespace
          span(class: "pr-1") { "uge 30" }
          whitespace
          span(class: "pr-1") { "20. september" }
          whitespace
          span(class: "pr-1") { "2024" }
        end
        div(class: "grid grid-flow-col") do
          p(class: "truncate") do
            "Klippe hæk - men herefter kommer der en kæmpelang beskrivelse"
          end
        end
      end
      div do
        whitespace
        svg(
          class: "text-gray-300",
          xmlns: "http://www.w3.org/2000/svg",
          height: "24px",
          viewbox: "0 -960 960 960",
          width: "24px",
          fill: "currentColor"
        ) do |s|
          s.path(
            d:
              "M480-160q-33 0-56.5-23.5T400-240q0-33 23.5-56.5T480-320q33 0 56.5 23.5T560-240q0 33-23.5 56.5T480-160Zm0-240q-33 0-56.5-23.5T400-480q0-33 23.5-56.5T480-560q33 0 56.5 23.5T560-480q0 33-23.5 56.5T480-400Zm0-240q-33 0-56.5-23.5T400-720q0-33 23.5-56.5T480-800q33 0 56.5 23.5T560-720q0 33-23.5 56.5T480-640Z"
          )
        end
      end
    end
    whitespace
    # comment/note
    li(class: "flex items-center p-1") do
      div(class: "flex flex-col flex-grow truncate") do
        div(class: "text-xs font-thin") do
          whitespace
          span { "08.00 - 14:45" }
          whitespace
          span { "torsdag" }
          whitespace
          span { "uge 30" }
          whitespace
          span { "20. september" }
          whitespace
          span { "2024" }
        end
        div(class: "grid grid-flow-col justify-start items-end") do
          whitespace
          svg(
            class: "mr-1 text-lime-400",
            xmlns: "http://www.w3.org/2000/svg",
            height: "24px",
            viewbox: "0 -960 960 960",
            width: "24px",
            fill: "currentColor"
          ) do |s|
            s.path(
              d:
                "M320-520q17 0 28.5-11.5T360-560q0-17-11.5-28.5T320-600q-17 0-28.5 11.5T280-560q0 17 11.5 28.5T320-520Zm160 0q17 0 28.5-11.5T520-560q0-17-11.5-28.5T480-600q-17 0-28.5 11.5T440-560q0 17 11.5 28.5T480-520Zm160 0q17 0 28.5-11.5T680-560q0-17-11.5-28.5T640-600q-17 0-28.5 11.5T600-560q0 17 11.5 28.5T640-520ZM80-80v-720q0-33 23.5-56.5T160-880h640q33 0 56.5 23.5T880-800v480q0 33-23.5 56.5T800-240H240L80-80Zm126-240h594v-480H160v525l46-45Zm-46 0v-480 480Z"
            )
          end
          p(class: "truncate") do
            "Klippe hæk - men herefter kommer der en kæmpelang beskrivelse"
          end
        end
      end
      div do
        whitespace
        svg(
          class: "text-gray-300",
          xmlns: "http://www.w3.org/2000/svg",
          height: "24px",
          viewbox: "0 -960 960 960",
          width: "24px",
          fill: "currentColor"
        ) do |s|
          s.path(
            d:
              "M480-160q-33 0-56.5-23.5T400-240q0-33 23.5-56.5T480-320q33 0 56.5 23.5T560-240q0 33-23.5 56.5T480-160Zm0-240q-33 0-56.5-23.5T400-480q0-33 23.5-56.5T480-560q33 0 56.5 23.5T560-480q0 33-23.5 56.5T480-400Zm0-240q-33 0-56.5-23.5T400-720q0-33 23.5-56.5T480-800q33 0 56.5 23.5T560-720q0 33-23.5 56.5T480-640Z"
          )
        end
      end
    end
  end
end

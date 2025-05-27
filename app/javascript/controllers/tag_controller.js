import { Controller } from "@hotwired/stimulus"
import { get } from "@rails/request.js";

// Connects to data-controller="tag"
export default class extends Controller {
  static targets = [
    "input",
    "output",
    "selectedTags",
    "tagList"]

  lastSearch = null;

  DEBOUNCE_TIMEOUT = 500; // milliseconds

  debouncePromise(fn, time) {
    let timeout;
    return (...args) => {
      return new Promise((resolve, reject) => {
        clearTimeout(timeout);
        timeout = setTimeout(() => {
          try {
            resolve(fn(...args));
            console.log(args)
          } catch (error) {
            reject(error);
          }
        }, time);
      }
      );
    };
  }

  debouncedLookup = this.debouncePromise(this.lookup.bind(this), this.DEBOUNCE_TIMEOUT);

  connect() {
    setTimeout(() => {
      if (this.inputTarget.textContent == undefined)
        this.inputTarget.textContent = "";
      this.lastSearch = this.inputTarget.textContent;
    },10)
  }

  // not working since blur will somehow loose the click event
  // which f*** up the tag selection
  //
  // blur(event) {
  //   console.log("Blur event triggered");
  //   // event.preventDefault();
  //   try {
  //     this.tagListTarget.classList.add("hidden");
  //     this.inputTarget.textContent = "";
  //   }
  //   catch (error) {
  //     console.log("Tag list not found");
  //   }
  //   this.lastSearch = null;
  // }

  focus(event) {
    event.preventDefault();

    const el = this.inputTarget;
    const sel = window.getSelection();
    sel.removeAllRanges();

    // Normalize in case there are multiple text nodes
    el.normalize();

    const textNode = el.firstChild;

    if (textNode && textNode.nodeType === Node.TEXT_NODE) {
      const range = document.createRange();
      // Force caret at END of the text node
      range.setStart(textNode, textNode.length);
      range.collapse(true);
      sel.addRange(range);
    } else {
      // Fallback: insert an empty text node and place caret there
      const fallback = document.createTextNode('');
      el.appendChild(fallback);
      const range = document.createRange();
      range.setStart(fallback, 0);
      range.collapse(true);
      sel.addRange(range);
    }
  }
  
  keyup(event){
    switch (event.key) {
      
      default:
        // this.lookup(event.target.textContent);
        this.debouncedLookup(event.target.textContent);
        break;
    }
  }

  keydown(event) {
    switch (event.key) {
      case ',':         this.stop_event(event); this.addTag();              break;
      case 'ArrowDown': this.stop_event(event); this.nextTagListItem();     break;
      case 'ArrowUp':   this.stop_event(event); this.nextTagListItem(true); break;
      case 'Enter':     this.enter_pick(event);                             break;
      case 'Tab':       this.tab_next(event);                               break;
      case 'Backspace': this.stop_event(event); this.doBackspace();         break;
      case 'Escape':
        if (!this.tagListTarget.classList.contains("hidden")) {
          this.tagListTarget.classList.add("hidden");
          this.stop_event(event);
        } else {
          if (this.inputTarget.textContent.length > 0) {
            this.inputTarget.textContent = "";
            this.stop_event(event);
          } 
        }
        break;
      default:
        break;
    }
  }

  stop_event(event) {
    event.preventDefault();
    event.stopPropagation();
  }

  nextTagListItem(reverse = false) {
    const tagList = this.tagListTarget;
    if (tagList) {
      const currentTag = tagList.querySelector('.current-tag-list-item');
      if (currentTag) {
        const nextTag = reverse ? currentTag.previousElementSibling : currentTag.nextElementSibling;
        if (nextTag) {
          currentTag.classList.remove('current-tag-list-item', 'bg-sky-100');
          nextTag.classList.add('current-tag-list-item', 'bg-sky-100');
        }
      } else {
        const firstTag = tagList.firstElementChild;
        if (firstTag) {
          firstTag.classList.add('current-tag-list-item', 'bg-sky-100');
        }
      }
    }
  }

  enter_pick(event) {
    let tag = this.tagListTarget.querySelector(".current-tag-list-item");
    if (tag) {
      this.stop_event(event); 
      this.selectTag(tag);
    }
  }

  pick(event) {
    let tag = event.target;

    if (tag.tagName === "SPAN") {
      tag = tag.parentElement;
    }
    if (tag) {
      this.selectTag(tag);
    }
  }

  tab_next(event) {
    this.tagListTarget.classList.add("hidden");
    this.inputTarget.textContent = "";
  }

  addTag() {
    let tags = this.outputTarget.value;
    let data = this.inputTarget.textContent;
    let url = encodeURI(`/tags/tags?add_tag=${data}&${this.get_context()}&value=${tags}`);
    this.get_url(url);
  }

  selectTag(tag) {
    if (this.outputTarget.value === undefined) {
      this.outputTarget.value = "";
    }
    if (tag.dataset.id === "0") {
      this.addTag();
    } else {
      let tags = this.outputTarget.value.split(",");
      tags.push(tag.dataset.id);
      let url = encodeURI(
        `/tags/tags?${this.get_context()}&value=${tags.join(",")}`
      );
      this.get_url(url);
    }
  }

  get_url(url) {
    get(url, {
      responseKind: "turbo-stream",
    });
  }

  removeTag(event) {
    event.preventDefault();
    const tag = event.currentTarget;
    const selectedTags = this.selectedTagsTarget;
    if (selectedTags) {
      const tagItem = selectedTags.querySelector(`[data-id="${tag.dataset.id}"]`);
      if (tagItem) {
        let tags = this.outputTarget.value.split(",");
        tags = tags.filter(t => t !== tag.dataset.id).join(",");

        let url = encodeURI( `/tags/tags?${this.get_context()}&search=${ this.inputTarget.textContent }&value=${tags}` );
        this.get_url(url);
      }
    }
  }

  lookup(txt) {
    if (txt.length > 1 && txt !== this.lastSearch) {
      this.lastSearch = txt;
      let tags = this.outputTarget.value.split(",");
      let url = encodeURI(
        `/tags/tags?${this.get_context()}&search=${txt}&value=${tags.join(",")}`
      );
      this.get_url(url);
    } else if (txt.length < 2) {
      try {
        this.tagListTarget.classList.add("hidden");
      } catch (error) {
      }
    }
  }

  get_context() {
    let context = this.outputTarget.dataset.context;
    let field = this.outputTarget.dataset.field;
    return `context=${context}&field=${field}`;
  }

  doBackspace() {

    const selectedTags = this.selectedTagsTarget;
    if (this.inputTarget.textContent.length === 0) {
      const lastTag = selectedTags.lastElementChild.previousElementSibling;
      if (lastTag) {
        this.inputTarget.textContent = lastTag.textContent;
        const tagId = lastTag.dataset.id;
        const tags = this.outputTarget.value.split(",");
        tags.pop();
        this.outputTarget.value = tags.join(",");
        lastTag.remove();
      }
    } else {
      this.inputTarget.textContent = this.inputTarget.textContent.slice(
        0,
        -1
      );

      if (this.inputTarget.textContent.length > 1) {
        this.lookup(this.inputTarget.textContent);
      } else {

        const textNode = this.inputTarget.firstChild;
        console.log( "Text node:", textNode?.nodeValue, "Length:", textNode?.length );
        this.tagList?.classList.add("hidden"); 
        this.placeCaretAtEnd();
      }
    }
  }

  placeCaretAtEnd() {
    this.inputTarget.focus();
    this.inputTarget.normalize(); // merge text nodes

    const sel = window.getSelection();
    const range = document.createRange();

    const textNode = this.inputTarget.firstChild;
    if (textNode && textNode.nodeType === Node.TEXT_NODE) {
      range.setStart(textNode, textNode.length);
      range.collapse(true);
      sel.removeAllRanges();
      sel.addRange(range);
    }
  }
  
  update(event) {
    const tag = this.element.querySelector('input[type="text"]')
    const tagList = this.tagListTarget
    const tagItem = document.createElement('li')
    tagItem.classList.add('tag-item')
    tagItem.textContent = tag.value
    tagItem.addEventListener('click', () => {
      tagItem.remove();
    });
    tagList.appendChild(tagItem)
    tag.value = ''
  }
}

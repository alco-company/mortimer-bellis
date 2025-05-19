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

  connect() {
    setTimeout(() => {
      if (this.inputTarget.textContent == undefined)
        this.inputTarget.textContent = "";
      this.lastSearch = this.inputTarget.textContent;
    },10)
    this.inputTarget.focus();
  }
  
  focus(event) {
    event.preventDefault();
    let caret = document.createRange();
    caret.selectNodeContents(this.inputTarget);
    caret.collapse(false);
    const sel = window.getSelection();
    sel.removeAllRanges();
    sel.addRange(caret);
  }

  keyup(event){
    switch (event.key) {
      
      default:
        this.lookup(event.target.textContent);
        break;
    }
  }

  keydown(event) {
    switch (event.key) {
      case ',':         event.stopPropagation(); this.addTag(event);                 break;
      case 'ArrowDown': event.stopPropagation(); this.nextTagListItem(event);        break;
      case 'ArrowUp':   event.stopPropagation(); this.nextTagListItem(event, true);  break;
      case 'Enter':     event.stopPropagation(); this.pick(event);                   break;
      case 'Backspace': event.stopPropagation(); this.doBackspace(event);            break;
      case 'Escape':
        event.preventDefault();
        this.element.querySelector('input[type="text"]').value = '';
        break;
      default:
        break;
    }
  }

  nextTagListItem(event, reverse = false) {
    event.preventDefault();
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

  pick(event) {
    event.preventDefault();
    if (this.outputTarget.value === undefined) {
      this.outputTarget.value = "";
    }
    let tags = this.outputTarget.value.split(",");
    let tag = this.tagListTarget.querySelector(".current-tag-list-item a");
    let url = "";
    if (tag) {
      if (tag.dataset.id === '0') {
        url = encodeURI(
          `/tags/tags?add_tag=${this.inputTarget.textContent}&value=${tags.join(",")}`
        );
      } else {
        tags.push(tag.dataset.id);
        url = encodeURI(
          `/tags/tags?value=${tags.join(",")}`
        );
      }
      get(url, {
        responseKind: "turbo-stream",
      });
    }
  }

  addTag(event) {
    event.preventDefault();
    let tags = this.outputTarget.value;
    let data = this.inputTarget.textContent;
    let url = encodeURI(`/tags/tags?add_tag=${data}&value=${tags}`);
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

        let url = encodeURI(`/tags/tags?search=${this.inputTarget.textContent}&value=${tags}`);
        get(url, {
          responseKind: "turbo-stream",
        });
      }
    }
  }

  lookup(txt) {
    if (txt.length > 1 && txt !== this.lastSearch) {
      this.lastSearch = txt;
      let tags = this.outputTarget.value.split(",");
      let url = encodeURI(`/tags/tags?search=${txt}&value=${tags.join(",")}`);
      get(url, {
        responseKind: "turbo-stream",
      });
    }
  }

  doBackspace(event) {
    event.preventDefault();

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
        tagList.classList.add("hidden");
        this.inputTarget.focus();
        this.inputTarget.setSelectionRange(
          this.inputTarget.value.length,
          this.inputTarget.value.length
        );
      }
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

import { Controller } from "@hotwired/stimulus";
import PhotoSwipeLightbox from 'photoswipe/lightbox';
import PhotoSwipe from 'photoswipe';

export default class extends Controller {
  connect() {
    const lightbox = new PhotoSwipeLightbox({
      gallery: `#${this.element.id}`,
      children: 'a',
      pswpModule: () => PhotoSwipe
    });
    lightbox.init();
  }
}

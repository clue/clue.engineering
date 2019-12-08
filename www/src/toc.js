const toc = document.querySelector('.toc');
const intro = document.querySelector('.intro');

let observerOptions = {
    rootMargin: '0px',
    threshold: 0
}

let stickToc = (entries, observer) => {
    entries.forEach(entry => {
        if (!entry.isIntersecting) {
            const tocHeight = toc.offsetHeight;
            toc.classList.add('stick');
            intro.setAttribute('style', `margin-bottom: ${tocHeight - 1}px`)
        } else {
            toc.classList.remove('stick');
            intro.setAttribute('style', `margin-bottom: 0px`)

        }
    })
}  
 
let observer = new IntersectionObserver(stickToc, observerOptions);

observer.observe(intro);
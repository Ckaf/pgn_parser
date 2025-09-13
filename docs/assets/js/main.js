// Main JavaScript for PGN Parser documentation

document.addEventListener('DOMContentLoaded', function() {
    // Mobile menu toggle
    const mobileMenuToggle = document.querySelector('.mobile-menu-toggle');
    const mainNav = document.querySelector('.main-nav');
    
    if (mobileMenuToggle && mainNav) {
        mobileMenuToggle.addEventListener('click', function() {
            mainNav.classList.toggle('active');
            mobileMenuToggle.classList.toggle('active');
        });
    }
    
    // Smooth scrolling for anchor links
    const anchorLinks = document.querySelectorAll('a[href^="#"]');
    anchorLinks.forEach(link => {
        link.addEventListener('click', function(e) {
            const targetId = this.getAttribute('href').substring(1);
            const targetElement = document.getElementById(targetId);
            
            if (targetElement) {
                e.preventDefault();
                targetElement.scrollIntoView({
                    behavior: 'smooth',
                    block: 'start'
                });
            }
        });
    });
    
    // Copy code blocks
    const codeBlocks = document.querySelectorAll('pre code');
    codeBlocks.forEach(block => {
        const button = document.createElement('button');
        button.className = 'copy-button';
        button.textContent = 'Copy';
        button.setAttribute('aria-label', 'Copy code to clipboard');
        
        const wrapper = document.createElement('div');
        wrapper.className = 'code-block-wrapper';
        wrapper.style.position = 'relative';
        
        block.parentNode.parentNode.insertBefore(wrapper, block.parentNode);
        wrapper.appendChild(block.parentNode);
        wrapper.appendChild(button);
        
        button.addEventListener('click', async function() {
            try {
                await navigator.clipboard.writeText(block.textContent);
                button.textContent = 'Copied!';
                button.classList.add('copied');
                
                setTimeout(() => {
                    button.textContent = 'Copy';
                    button.classList.remove('copied');
                }, 2000);
            } catch (err) {
                console.error('Failed to copy text: ', err);
                button.textContent = 'Failed';
                setTimeout(() => {
                    button.textContent = 'Copy';
                }, 2000);
            }
        });
    });
    
    // Table of contents generation
    generateTableOfContents();
    
    // Search functionality
    initializeSearch();
    
    // Theme toggle
    initializeThemeToggle();
    
    // Syntax highlighting for OCaml code
    highlightOCamlCode();
});

// Generate table of contents
function generateTableOfContents() {
    const content = document.querySelector('.content-body');
    if (!content) return;
    
    const headings = content.querySelectorAll('h2, h3, h4');
    if (headings.length < 2) return;
    
    const toc = document.createElement('div');
    toc.className = 'table-of-contents';
    toc.innerHTML = '<h3>Table of Contents</h3><ul></ul>';
    
    const tocList = toc.querySelector('ul');
    
    headings.forEach((heading, index) => {
        const id = `heading-${index}`;
        heading.id = id;
        
        const li = document.createElement('li');
        li.className = `toc-${heading.tagName.toLowerCase()}`;
        
        const a = document.createElement('a');
        a.href = `#${id}`;
        a.textContent = heading.textContent;
        a.className = 'toc-link';
        
        li.appendChild(a);
        tocList.appendChild(li);
    });
    
    content.insertBefore(toc, content.firstChild);
}

// Initialize search functionality
function initializeSearch() {
    const searchInput = document.createElement('input');
    searchInput.type = 'text';
    searchInput.placeholder = 'Search documentation...';
    searchInput.className = 'search-input';
    
    const searchResults = document.createElement('div');
    searchResults.className = 'search-results';
    searchResults.style.display = 'none';
    
    const searchContainer = document.createElement('div');
    searchContainer.className = 'search-container';
    searchContainer.appendChild(searchInput);
    searchContainer.appendChild(searchResults);
    
    const sidebar = document.querySelector('.sidebar');
    if (sidebar) {
        sidebar.insertBefore(searchContainer, sidebar.firstChild);
    }
    
    let searchTimeout;
    searchInput.addEventListener('input', function() {
        clearTimeout(searchTimeout);
        searchTimeout = setTimeout(() => {
            performSearch(this.value, searchResults);
        }, 300);
    });
}

// Perform search
function performSearch(query, resultsContainer) {
    if (query.length < 2) {
        resultsContainer.style.display = 'none';
        return;
    }
    
    const content = document.querySelector('.content-body');
    if (!content) return;
    
    const searchResults = [];
    const elements = content.querySelectorAll('h1, h2, h3, h4, h5, h6, p, li, code');
    
    elements.forEach(element => {
        const text = element.textContent.toLowerCase();
        if (text.includes(query.toLowerCase())) {
            const heading = element.closest('h1, h2, h3, h4, h5, h6') || element;
            const result = {
                title: heading.textContent,
                content: element.textContent.substring(0, 150) + '...',
                element: element
            };
            searchResults.push(result);
        }
    });
    
    displaySearchResults(searchResults, resultsContainer, query);
}

// Display search results
function displaySearchResults(results, container, query) {
    if (results.length === 0) {
        container.innerHTML = '<p>No results found</p>';
        container.style.display = 'block';
        return;
    }
    
    const html = results.slice(0, 5).map(result => `
        <div class="search-result">
            <h4><a href="#${result.element.id || ''}">${highlightText(result.title, query)}</a></h4>
            <p>${highlightText(result.content, query)}</p>
        </div>
    `).join('');
    
    container.innerHTML = html;
    container.style.display = 'block';
}

// Highlight search terms
function highlightText(text, query) {
    const regex = new RegExp(`(${query})`, 'gi');
    return text.replace(regex, '<mark>$1</mark>');
}

// Initialize theme toggle
function initializeThemeToggle() {
    const themeToggle = document.createElement('button');
    themeToggle.className = 'theme-toggle';
    themeToggle.innerHTML = '🌙';
    themeToggle.setAttribute('aria-label', 'Toggle dark mode');
    
    const header = document.querySelector('.header-content');
    if (header) {
        header.appendChild(themeToggle);
    }
    
    // Check for saved theme preference
    const savedTheme = localStorage.getItem('theme');
    if (savedTheme) {
        document.documentElement.setAttribute('data-theme', savedTheme);
        updateThemeIcon(themeToggle, savedTheme);
    }
    
    themeToggle.addEventListener('click', function() {
        const currentTheme = document.documentElement.getAttribute('data-theme');
        const newTheme = currentTheme === 'dark' ? 'light' : 'dark';
        
        document.documentElement.setAttribute('data-theme', newTheme);
        localStorage.setItem('theme', newTheme);
        updateThemeIcon(this, newTheme);
    });
}

// Update theme icon
function updateThemeIcon(button, theme) {
    button.innerHTML = theme === 'dark' ? '☀️' : '🌙';
}

// Highlight OCaml code
function highlightOCamlCode() {
    const codeBlocks = document.querySelectorAll('pre code');
    codeBlocks.forEach(block => {
        if (block.textContent.includes('open ') || 
            block.textContent.includes('let ') || 
            block.textContent.includes('match ') ||
            block.textContent.includes('type ')) {
            block.classList.add('language-ocaml');
        }
    });
}

// Add CSS for new elements
const additionalStyles = `
    .code-block-wrapper {
        position: relative;
    }
    
    .copy-button {
        position: absolute;
        top: 0.5rem;
        right: 0.5rem;
        background: var(--bg-secondary);
        border: 1px solid var(--border-color);
        border-radius: var(--radius-sm);
        padding: 0.25rem 0.5rem;
        font-size: 0.75rem;
        cursor: pointer;
        transition: all 0.2s ease;
    }
    
    .copy-button:hover {
        background: var(--primary-color);
        color: white;
        border-color: var(--primary-color);
    }
    
    .copy-button.copied {
        background: var(--success-color);
        color: white;
        border-color: var(--success-color);
    }
    
    .table-of-contents {
        background: var(--bg-secondary);
        border: 1px solid var(--border-color);
        border-radius: var(--radius-md);
        padding: 1.5rem;
        margin-bottom: 2rem;
    }
    
    .table-of-contents h3 {
        margin-top: 0;
        margin-bottom: 1rem;
        font-size: 1rem;
        color: var(--text-secondary);
    }
    
    .table-of-contents ul {
        list-style: none;
        padding: 0;
        margin: 0;
    }
    
    .table-of-contents li {
        margin-bottom: 0.5rem;
    }
    
    .table-of-contents .toc-h2 {
        font-weight: 600;
    }
    
    .table-of-contents .toc-h3 {
        padding-left: 1rem;
        font-size: 0.875rem;
    }
    
    .table-of-contents .toc-h4 {
        padding-left: 2rem;
        font-size: 0.875rem;
    }
    
    .toc-link {
        color: var(--text-secondary);
        text-decoration: none;
        transition: color 0.2s ease;
    }
    
    .toc-link:hover {
        color: var(--primary-color);
    }
    
    .search-container {
        margin-bottom: 2rem;
    }
    
    .search-input {
        width: 100%;
        padding: 0.75rem;
        border: 1px solid var(--border-color);
        border-radius: var(--radius-md);
        background: var(--bg-primary);
        color: var(--text-primary);
        font-size: 0.875rem;
    }
    
    .search-input:focus {
        outline: none;
        border-color: var(--primary-color);
        box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.1);
    }
    
    .search-results {
        background: var(--bg-primary);
        border: 1px solid var(--border-color);
        border-radius: var(--radius-md);
        margin-top: 0.5rem;
        max-height: 300px;
        overflow-y: auto;
    }
    
    .search-result {
        padding: 1rem;
        border-bottom: 1px solid var(--border-color);
    }
    
    .search-result:last-child {
        border-bottom: none;
    }
    
    .search-result h4 {
        margin: 0 0 0.5rem 0;
        font-size: 0.875rem;
    }
    
    .search-result p {
        margin: 0;
        font-size: 0.75rem;
        color: var(--text-secondary);
    }
    
    .search-result a {
        color: var(--primary-color);
        text-decoration: none;
    }
    
    .search-result a:hover {
        text-decoration: underline;
    }
    
    .search-result mark {
        background: var(--accent-color);
        color: white;
        padding: 0.125rem 0.25rem;
        border-radius: var(--radius-sm);
    }
    
    .theme-toggle {
        background: none;
        border: 1px solid var(--border-color);
        border-radius: var(--radius-md);
        padding: 0.5rem;
        cursor: pointer;
        font-size: 1.25rem;
        transition: all 0.2s ease;
    }
    
    .theme-toggle:hover {
        background: var(--bg-secondary);
        border-color: var(--border-hover);
    }
    
    .main-nav.active {
        display: block;
        position: absolute;
        top: 100%;
        left: 0;
        right: 0;
        background: var(--bg-primary);
        border: 1px solid var(--border-color);
        border-radius: var(--radius-md);
        padding: 1rem;
        box-shadow: var(--shadow-lg);
    }
    
    .main-nav.active ul {
        flex-direction: column;
        gap: 1rem;
    }
    
    .mobile-menu-toggle.active span:nth-child(1) {
        transform: rotate(45deg) translate(5px, 5px);
    }
    
    .mobile-menu-toggle.active span:nth-child(2) {
        opacity: 0;
    }
    
    .mobile-menu-toggle.active span:nth-child(3) {
        transform: rotate(-45deg) translate(7px, -6px);
    }
    
    @media (max-width: 768px) {
        .main-nav {
            display: none;
        }
    }
`;

// Inject additional styles
const styleSheet = document.createElement('style');
styleSheet.textContent = additionalStyles;
document.head.appendChild(styleSheet);

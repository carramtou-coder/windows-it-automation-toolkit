"use strict";

const translations = {
  en: {
    brandHome:"Carl Ramses Toussaint, home",mainNav:"Main navigation",
    visualLabel:"A simple illustration of an IT health report",
    techLabel:"Technologies shown in the repository",filterGroupLabel:"Filter projects",
    skip:"Skip to content",navAbout:"About",navProjects:"Projects",navWorkflows:"Automations",navApproach:"Approach",navContact:"Contact",
    heroEyebrow:"IT SUPPORT · SYSTEMS · AUTOMATION",heroTitle:"Good IT work makes the next step clear.",
    heroLead:"I build practical, read-only tools that help technicians understand endpoint health, review operational signals, and decide what to do next.",
    ctaProjects:"Explore the projects",ctaGithub:"View GitHub repository",heroNote:"Small tools. Clear reports. Technician stays in control.",
    reportLabel:"FIELD NOTES / 01",reportTitle:"Endpoint snapshot",reportSubtitle:"A quick view of what needs attention.",
    reportInventory:"Device inventory",reportServices:"Service checks",reportDisk:"Disk space review",reportReady:"READY",
    reportReview:"REVIEW",reportGenerated:"READ-ONLY · HUMAN REVIEW",visualCaption:"Observe → summarize → hand off",
    introText:"A practical portfolio built around day-to-day IT operations, with clear boundaries between reporting and action.",
    introStat:"sample projects",aboutEyebrow:"A LITTLE ABOUT MY WORK",
    aboutTitle:"Useful tools start with a real support problem.",
    aboutLead:"My focus is the space between a technical signal and a useful next step. These examples turn device checks and exported service data into reports a technician can review.",
    aboutDetailOne:"The projects use PowerShell, Windows built-ins, Microsoft Graph, and normalized CSV exports. They are designed to be easy to inspect and adapt.",
    aboutDetailTwo:"The examples are deliberately read-only: they report findings and leave the operational decision with the technician.",
    projectsEyebrow:"SELECTED WORK",projectsTitle:"Projects that make the work easier to see.",
    projectsLead:"Explore the code and sample workflows in the Windows and Microsoft 365 toolkit.",
    allSource:"All source code",filterAll:"All",filterEndpoint:"Endpoint",filterM365:"Microsoft 365",filterMsp:"MSP workflow",
    searchLabel:"Search projects",searchPlaceholder:"Search projects or tools",
    categoryEndpoint:"ENDPOINT OPERATIONS",categoryM365:"MICROSOFT 365",categoryMsp:"MSP OPERATIONS",
    projectAuditTitle:"Windows read-only audit",
    projectAuditText:"Combines device inventory, low-disk checks, selected service checks, and a summary of recent critical and error events.",
    projectIntuneTitle:"Intune device report",
    projectIntuneText:"Reads managed-device compliance and sync status through Microsoft Graph, with pagination and stale-device summaries.",
    projectBackupTitle:"Backup compliance report",
    projectBackupText:"Turns a normalized CSV export into a client and device summary, plus a focused list of backup and restore-test exceptions.",
    projectTriageTitle:"PSA / RMM triage report",
    projectTriageText:"Matches ticket and alert exports by client and device, then creates a review queue for unlinked alerts, priorities, repeats, and SLA deadlines.",
    viewSource:"View source",emptyProjects:"No projects match that search. Try another word or category.",
    workflowsEyebrow:"AUTOMATION IN THE REPOSITORY",
    workflowsTitle:"Five workflows that keep the tools ready to use.",
    workflowsLead:"GitHub Actions checks code changes, publishes this site, and packages tagged releases.",
    workflowTriggerChanges:"SCRIPT CHANGES",workflowTriggerSite:"SITE CHANGES",
    workflowTriggerDeploy:"MAIN OR MANUAL",workflowTriggerTag:"VERSION TAG",
    workflowAnalysisTitle:"PowerShell static analysis",
    workflowAnalysisText:"Runs PSScriptAnalyzer on pull requests and main-branch changes. Analyzer errors are shown in the Actions run so issues can be fixed before the scripts are used.",
    workflowCompatibilityTitle:"PowerShell compatibility",
    workflowCompatibilityText:"Parses the repository’s PowerShell files with Windows PowerShell 5.1 and PowerShell 7 on Windows to catch syntax differences early.",
    workflowValidationTitle:"Portfolio quality checks",
    workflowValidationText:"On portfolio changes, checks JavaScript syntax and confirms local files and in-page links resolve, so missing assets and broken sections appear in the Actions run.",
    workflowDeployTitle:"GitHub Pages deployment",
    workflowDeployText:"Publishes the portfolio-site folder when it changes on main, or when manually started from the Actions tab.",
    workflowReleaseTitle:"Tagged release packaging",
    workflowReleaseText:"When a version tag such as v1.0.0 is pushed, creates a ZIP of the source and a SHA-256 checksum as a downloadable Actions artifact.",
    workflowSource:"View workflow",
    approachEyebrow:"HOW I APPROACH IT OPERATIONS",
    approachTitle:"Make the signal clear. Keep the next step human.",
    approachLead:"A good operational report is useful, understandable, and careful about what it changes.",
    stepOneTitle:"Observe",stepOneText:"Collect only the information needed for the check.",
    stepTwoTitle:"Summarize",stepTwoText:"Show exceptions in a format that is quick to review.",
    stepThreeTitle:"Review",stepThreeText:"Give the technician context and leave the action in their hands.",
    contactEyebrow:"LET'S CONNECT",contactTitle:"Want to see how one of these tools works?",
    contactText:"Browse the source, sample data, and project notes on GitHub.",
    contactButton:"Visit my GitHub profile",footerNote:"Built with care. No tracking. No external libraries.",
    backTop:"Back to top",languageLabel:"Switch language to French",themeDarkLabel:"Switch to dark theme",
    themeLightLabel:"Switch to light theme",openNav:"Open navigation",closeNav:"Close navigation",
    projectCountOne:"Showing 1 project",projectCountMany:"Showing {count} projects"
  },
  fr: {
    brandHome:"Accueil — Carl Ramses Toussaint",mainNav:"Navigation principale",
    visualLabel:"Illustration d’un rapport sur l’état d’un poste informatique",
    techLabel:"Technologies présentées dans le dépôt",filterGroupLabel:"Filtrer les projets",
    skip:"Passer au contenu",navAbout:"À propos",navProjects:"Projets",navWorkflows:"Automatisations",navApproach:"Approche",navContact:"Contact",
    heroEyebrow:"SOUTIEN TI · SYSTÈMES · AUTOMATISATION",heroTitle:"Un bon soutien TI clarifie la prochaine étape.",
    heroLead:"Je crée des outils pratiques en lecture seule qui aident les techniciens à comprendre l’état des postes, à examiner les signaux opérationnels et à choisir la suite.",
    ctaProjects:"Découvrir les projets",ctaGithub:"Voir le dépôt GitHub",
    heroNote:"Des outils simples. Des rapports clairs. Le technicien garde le contrôle.",
    reportLabel:"NOTES DE TERRAIN / 01",reportTitle:"Aperçu du poste",
    reportSubtitle:"Un aperçu rapide des points à vérifier.",reportInventory:"Inventaire du poste",
    reportServices:"Vérification des services",reportDisk:"Espace disque",reportReady:"PRÊT",
    reportReview:"À VÉRIFIER",reportGenerated:"LECTURE SEULE · RÉVISION HUMAINE",
    visualCaption:"Observer → résumer → transmettre",
    introText:"Un portfolio pratique axé sur les opérations TI quotidiennes, avec une distinction claire entre les rapports et les actions.",
    introStat:"projets exemples",aboutEyebrow:"À PROPOS DE MON TRAVAIL",
    aboutTitle:"Les outils utiles partent d’un vrai besoin de soutien.",
    aboutLead:"Je m’intéresse au passage entre un signal technique et une prochaine étape utile. Ces exemples transforment des vérifications de postes et des exports de service en rapports qu’un technicien peut examiner.",
    aboutDetailOne:"Les projets utilisent PowerShell, les outils intégrés de Windows, Microsoft Graph et des exports CSV normalisés. Le code est conçu pour être facile à examiner et à adapter.",
    aboutDetailTwo:"Les exemples sont volontairement en lecture seule : ils présentent les constats et laissent la décision opérationnelle au technicien.",
    projectsEyebrow:"PROJETS CHOISIS",projectsTitle:"Des projets qui rendent le travail plus visible.",
    projectsLead:"Explorez le code et les exemples de flux de travail du coffre à outils Windows et Microsoft 365.",
    allSource:"Tout le code source",filterAll:"Tout",filterEndpoint:"Postes",
    filterM365:"Microsoft 365",filterMsp:"Flux MSP",searchLabel:"Rechercher des projets",
    searchPlaceholder:"Rechercher un projet ou un outil",
    categoryEndpoint:"OPÉRATIONS DES POSTES",categoryM365:"MICROSOFT 365",categoryMsp:"OPÉRATIONS MSP",
    projectAuditTitle:"Audit Windows en lecture seule",
    projectAuditText:"Réunit l’inventaire du poste, l’espace disque, certains services et un résumé des événements critiques et erreurs récents.",
    projectIntuneTitle:"Rapport des appareils Intune",
    projectIntuneText:"Lit la conformité et la date de synchronisation des appareils gérés avec Microsoft Graph, avec pagination et résumé des appareils inactifs.",
    projectBackupTitle:"Rapport de conformité des sauvegardes",
    projectBackupText:"Transforme un export CSV normalisé en résumé par client et appareil, avec une liste des exceptions de sauvegarde et de tests de restauration.",
    projectTriageTitle:"Rapport de triage PSA / RMM",
    projectTriageText:"Associe les exports de billets et d’alertes par client et appareil, puis crée une file de révision pour les alertes, priorités, répétitions et échéances SLA.",
    viewSource:"Voir le code",emptyProjects:"Aucun projet ne correspond. Essayez un autre mot ou une autre catégorie.",
    workflowsEyebrow:"AUTOMATISATION DU DÉPÔT",
    workflowsTitle:"Cinq flux qui gardent les outils prêts à servir.",
    workflowsLead:"GitHub Actions vérifie les changements de code, publie le site et prépare les versions marquées.",
    workflowTriggerChanges:"CHANGEMENT DE SCRIPT",workflowTriggerSite:"CHANGEMENT DU SITE",
    workflowTriggerDeploy:"BRANCHE MAIN OU MANUEL",workflowTriggerTag:"ÉTIQUETTE DE VERSION",
    workflowAnalysisTitle:"Analyse statique PowerShell",
    workflowAnalysisText:"Exécute PSScriptAnalyzer lors des demandes de fusion et des changements sur main. Les erreurs apparaissent dans l’exécution Actions pour être corrigées avant l’utilisation des scripts.",
    workflowCompatibilityTitle:"Compatibilité PowerShell",
    workflowCompatibilityText:"Vérifie l’analyse syntaxique des fichiers PowerShell avec Windows PowerShell 5.1 et PowerShell 7 sous Windows afin de repérer les différences tôt.",
    workflowValidationTitle:"Vérifications du portfolio",
    workflowValidationText:"Lors des changements au portfolio, vérifie la syntaxe JavaScript et confirme que les fichiers locaux et les liens internes fonctionnent. Les fichiers manquants et liens brisés apparaissent dans Actions.",
    workflowDeployTitle:"Publication avec GitHub Pages",
    workflowDeployText:"Publie le dossier portfolio-site lorsqu’il change sur main, ou lorsqu’on lance le flux manuellement dans l’onglet Actions.",
    workflowReleaseTitle:"Préparation des versions marquées",
    workflowReleaseText:"Lorsqu’une étiquette de version comme v1.0.0 est poussée, crée une archive ZIP et une somme SHA-256 en tant qu’artefact téléchargeable dans Actions.",
    workflowSource:"Voir le flux",
    approachEyebrow:"MON APPROCHE DES OPÉRATIONS TI",
    approachTitle:"Clarifier le signal. Garder la prochaine étape humaine.",
    approachLead:"Un bon rapport opérationnel est utile, compréhensible et prudent quant aux changements qu’il apporte.",
    stepOneTitle:"Observer",stepOneText:"Recueillir uniquement les données nécessaires à la vérification.",
    stepTwoTitle:"Résumer",stepTwoText:"Présenter les exceptions dans un format rapide à examiner.",
    stepThreeTitle:"Réviser",stepThreeText:"Donner du contexte au technicien et lui laisser la décision.",
    contactEyebrow:"RESTONS EN CONTACT",
    contactTitle:"Vous voulez voir comment fonctionne l’un de ces outils ?",
    contactText:"Consultez le code, les données exemples et les notes des projets sur GitHub.",
    contactButton:"Visiter mon profil GitHub",
    footerNote:"Créé avec soin. Sans suivi ni bibliothèque externe.",backTop:"Retour en haut",
    languageLabel:"Passer à l’anglais",themeDarkLabel:"Activer le thème sombre",
    themeLightLabel:"Activer le thème clair",openNav:"Ouvrir la navigation",closeNav:"Fermer la navigation",
    projectCountOne:"1 projet affiché",projectCountMany:"{count} projets affichés"
  }
};

const root = document.documentElement;
const cards = Array.from(document.querySelectorAll(".project-card"));
const filterButtons = Array.from(document.querySelectorAll("[data-filter]"));
const searchInput = document.getElementById("project-search");
const countOutput = document.getElementById("filter-count");
const emptyState = document.getElementById("empty-state");
const menuToggle = document.getElementById("menu-toggle");
const siteNav = document.getElementById("site-nav");
const languageToggle = document.getElementById("language-toggle");
const themeToggle = document.getElementById("theme-toggle");
const siteHeader = document.querySelector(".site-header");
let currentFilter = "all";
let currentLanguage = "en";

function readPreference(key) {
  try { return window.localStorage.getItem(key); }
  catch (error) { return null; }
}
function savePreference(key,value) {
  try { window.localStorage.setItem(key,value); }
  catch (error) { /* Preference still applies for this page view. */ }
}
function setLanguage(language) {
  currentLanguage = language === "fr" ? "fr" : "en";
  root.lang = currentLanguage;
  root.dataset.language = currentLanguage;
  const dictionary = translations[currentLanguage];
  document.querySelectorAll("[data-i18n]").forEach(function (element) {
    const key = element.dataset.i18n;
    if (Object.prototype.hasOwnProperty.call(dictionary,key)) element.textContent = dictionary[key];
  });
  document.querySelectorAll("[data-i18n-placeholder]").forEach(function (element) {
    const key = element.dataset.i18nPlaceholder;
    if (Object.prototype.hasOwnProperty.call(dictionary,key)) element.setAttribute("placeholder",dictionary[key]);
  });
  document.querySelectorAll("[data-i18n-aria-label]").forEach(function (element) {
    const key = element.dataset.i18nAriaLabel;
    if (Object.prototype.hasOwnProperty.call(dictionary,key)) element.setAttribute("aria-label",dictionary[key]);
  });
  languageToggle.textContent = currentLanguage === "en" ? "FR" : "EN";
  languageToggle.setAttribute("aria-label",dictionary.languageLabel);
  languageToggle.title = dictionary.languageLabel;
  updateThemeLabel();
  updateMenuLabel();
  updateProjectView();
  savePreference("portfolio-language",currentLanguage);
}
function updateThemeLabel() {
  const dictionary = translations[currentLanguage];
  const label = root.dataset.theme === "dark" ? dictionary.themeLightLabel : dictionary.themeDarkLabel;
  themeToggle.setAttribute("aria-label",label);
  themeToggle.title = label;
}
function setTheme(theme) {
  root.dataset.theme = theme === "dark" ? "dark" : "light";
  updateThemeLabel();
  savePreference("portfolio-theme",root.dataset.theme);
}
function updateMenuLabel() {
  const dictionary = translations[currentLanguage];
  const isOpen = menuToggle.getAttribute("aria-expanded") === "true";
  const label = isOpen ? dictionary.closeNav : dictionary.openNav;
  menuToggle.setAttribute("aria-label",label);
  menuToggle.title = label;
}
function updateProjectView() {
  const query = searchInput.value.trim().toLocaleLowerCase(currentLanguage);
  let visibleCount = 0;
  cards.forEach(function (card) {
    const categoryMatch = currentFilter === "all" || card.dataset.category === currentFilter;
    const text = (card.dataset.search + " " + card.textContent).toLocaleLowerCase(currentLanguage);
    const searchMatch = query.length === 0 || text.includes(query);
    card.hidden = !(categoryMatch && searchMatch);
    if (!card.hidden) visibleCount += 1;
  });
  emptyState.hidden = visibleCount !== 0;
  const dictionary = translations[currentLanguage];
  countOutput.textContent = visibleCount === 1 ? dictionary.projectCountOne : dictionary.projectCountMany.replace("{count}",String(visibleCount));
}

filterButtons.forEach(function (button) {
  button.addEventListener("click",function () {
    currentFilter = button.dataset.filter;
    filterButtons.forEach(function (item) {
      const active = item === button;
      item.classList.toggle("is-active",active);
      item.setAttribute("aria-pressed",String(active));
    });
    updateProjectView();
  });
});
searchInput.addEventListener("input",updateProjectView);
languageToggle.addEventListener("click",function () { setLanguage(currentLanguage === "en" ? "fr" : "en"); });
themeToggle.addEventListener("click",function () { setTheme(root.dataset.theme === "dark" ? "light" : "dark"); });
menuToggle.addEventListener("click",function () {
  const open = menuToggle.getAttribute("aria-expanded") !== "true";
  menuToggle.setAttribute("aria-expanded",String(open));
  siteNav.classList.toggle("is-open",open);
  updateMenuLabel();
});
siteNav.querySelectorAll("a").forEach(function (link) {
  link.addEventListener("click",function () {
    menuToggle.setAttribute("aria-expanded","false");
    siteNav.classList.remove("is-open");
    updateMenuLabel();
  });
});
document.addEventListener("keydown",function (event) {
  if (event.key === "Escape" && menuToggle.getAttribute("aria-expanded") === "true") {
    menuToggle.setAttribute("aria-expanded","false");
    siteNav.classList.remove("is-open");
    menuToggle.focus();
    updateMenuLabel();
  }
  if (event.key === "/" && !event.ctrlKey && !event.metaKey && !event.altKey) {
    const tag = document.activeElement && document.activeElement.tagName;
    if (!["INPUT","TEXTAREA"].includes(tag)) {
      event.preventDefault();
      searchInput.focus();
    }
  }
});
window.addEventListener("scroll",function () { siteHeader.classList.toggle("is-scrolled",window.scrollY > 8); },{passive:true});
document.getElementById("current-year").textContent = String(new Date().getFullYear());

const savedTheme = readPreference("portfolio-theme");
const prefersDark = window.matchMedia && window.matchMedia("(prefers-color-scheme: dark)").matches;
setTheme(savedTheme || (prefersDark ? "dark" : "light"));
setLanguage(readPreference("portfolio-language") || "en");

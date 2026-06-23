export const manifest = {
  screens: {
    scr_64fg1i: { name: "1. Главная", route: "/", state: { "screen": "home" } },
    scr_23a7x6: { name: "2. Проблемы", route: "/", state: { "screen": "issues" } },
    scr_hvg5iq: { name: "3. Чат проблемы", route: "/", state: { "screen": "issue-chat" } },
    scr_4vohgs: { name: "4. Договорённости", route: "/", state: { "screen": "agreements" } },
    scr_dn4u9y: { name: "5. Активности", route: "/", state: { "screen": "activities" } },
    scr_g351i0: { name: "6. Случайная активность", route: "/", state: { "screen": "random-activity" } },
    scr_mpnqml: { name: "7. Создать проблему", route: "/", state: { "screen": "create-issue" } },
    scr_wpnt85: { name: "8. Профиль", route: "/", state: { "screen": "profile" } },
    scr_3eth1q: { name: "9. Квиз", route: "/", state: { "screen": "quiz" } },
    scr_s5lkjb: { name: "10. Результат квиза", route: "/", state: { "screen": "quiz-result" } },
    scr_nttk1h: { name: "11. Онбординг 1", route: "/", state: { "screen": "onboarding-1" } },
    scr_dt7sa8: { name: "12. Онбординг 2", route: "/", state: { "screen": "onboarding-2" } },
    scr_zsifke: { name: "13. Онбординг 3", route: "/", state: { "screen": "onboarding-3" } },
    scr_zbxl5z: { name: "14. Вход", route: "/", state: { "screen": "login" } },
    scr_8fi4ai: { name: "15. Регистрация", route: "/", state: { "screen": "register" } },
    scr_dcja7u: { name: "16. Забыли пароль", route: "/", state: { "screen": "forgot-password" } },
    scr_17r27u: { name: "17. Подтверждение возраста", route: "/", state: { "screen": "age-gate" } },
    scr_rfae45: { name: "18. Создать/Присоединиться", route: "/", state: { "screen": "create-join-couple" } },
    scr_a88a2h: { name: "19. Код приглашения", route: "/", state: { "screen": "invite-code" } },
    scr_zvcx0w: { name: "20. Ввод кода", route: "/", state: { "screen": "enter-code" } },
    scr_ch0qhl: { name: "21. Пара создана", route: "/", state: { "screen": "couple-success" } },
    scr_b21a1n: { name: "22. Настройки уведомлений", route: "/", state: { "screen": "notifications-settings" } },
    scr_qklx1d: { name: "23. Безопасность", route: "/", state: { "screen": "security-safety" } },
    scr_mtuo9t: { name: "24. Удаление аккаунта", route: "/", state: { "screen": "delete-account" } }
  },
  sections: {
    sec_oddz70: { name: "Main Dashboard Flow", x: 0, y: 0, width: 5720, height: 1180 },
    sec_1o13th: { name: "Activities Flow", x: 0, y: 1980, width: 2920, height: 1180 },
    sec_2jj2gy: { name: "Quiz Flow", x: 0, y: 3960, width: 2920, height: 1180 },
    sec_kem11x: { name: "Problem Creation", x: 0, y: 5940, width: 1520, height: 1180 },
    sec_j6hted: { name: "User Profile", x: 0, y: 7920, width: 1520, height: 1180 }
  },
  layers: [
  { kind: "section", id: "sec_oddz70", children: [
    { kind: "screen", id: "scr_rvzm3u" },
    { kind: "screen", id: "scr_xrm4y8" },
    { kind: "screen", id: "scr_lebvkx" },
    { kind: "screen", id: "scr_py4iri" }]
  },
  { kind: "section", id: "sec_1o13th", children: [
    { kind: "screen", id: "scr_srwwfk" },
    { kind: "screen", id: "scr_95v3w8" }]
  },
  { kind: "section", id: "sec_2jj2gy", children: [
    { kind: "screen", id: "scr_5t3ijt" },
    { kind: "screen", id: "scr_d0t7zm" }]
  },
  { kind: "section", id: "sec_kem11x", children: [
    { kind: "screen", id: "scr_5dtgfr" }]
  },
  { kind: "section", id: "sec_j6hted", children: [
    { kind: "screen", id: "scr_6l1fam" }]
  }]

};
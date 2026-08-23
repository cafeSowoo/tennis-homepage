(function () {
  "use strict";

  const CONFIG = window.TENNIS_CONFIG || {};
  const MONTH_PATTERN = /^\d{4}-(0[1-9]|1[0-2])$/;
  const DATE_PATTERN = /^\d{4}-(0[1-9]|1[0-2])-([0-2]\d|3[01])$/;
  const MALE_MEMBER_NAMES = new Set(["조형철", "김지석", "한인호", "김태환", "이상백", "민문기", "박창언", "윤준"]);
  const PRIVATE_COURT_IDS = new Set(["court-yonsei-tennis"]);
  const state = {
    members: [],
    courts: [],
    courtUnits: [],
    schedules: [],
    month: initialMonth(),
    selectedDate: initialDate(),
    source: "remote"
  };
  let toastTimer = 0;
  const els = {};

  if (state.selectedDate && state.selectedDate.slice(0, 7) !== state.month) {
    state.month = state.selectedDate.slice(0, 7);
  }

  document.addEventListener("DOMContentLoaded", init);

  async function init() {
    cacheElements();
    bindEvents();
    renderMonthShell();

    try {
      const data = await loadScheduleData();
      state.members = data.members;
      state.courts = data.courts;
      state.courtUnits = data.courtUnits;
      state.schedules = data.schedules.sort(compareSchedules);
      state.source = data.source;
      renderAll();
      setSyncStatus(
        data.source === "remote" ? "관리자 일정과 동기화됨" : "저장된 일정을 표시 중",
        "live"
      );
    } catch (error) {
      console.error("Club schedule could not be loaded.", error);
      setSyncStatus("일정을 불러오지 못했어요", "error");
      renderLoadError();
    }
  }

  function cacheElements() {
    [
      "sharePageButton", "syncLabel", "previousMonthButton", "nextMonthButton",
      "calendarMonthTitle", "calendarGrid", "selectedDatePanel", "selectedDateTitle",
      "selectedDateList", "closeSelectedDateButton", "toast"
    ].forEach(id => { els[id] = document.getElementById(id); });
  }

  function bindEvents() {
    els.previousMonthButton.addEventListener("click", () => changeMonth(-1));
    els.nextMonthButton.addEventListener("click", () => changeMonth(1));
    els.closeSelectedDateButton.addEventListener("click", clearSelectedDate);
    els.sharePageButton.addEventListener("click", () => shareContent({
      title: "아직도 성장중 · 클럽 일정",
      text: "클럽 경기 일정을 확인해 주세요.",
      url: cleanPageUrl()
    }));

    els.calendarGrid.addEventListener("click", event => {
      const button = event.target.closest("[data-date]");
      if (!button) return;
      state.selectedDate = button.dataset.date;
      syncUrlState();
      renderCalendar();
      renderSelectedDate();

      if (window.innerWidth >= 768) {
        requestAnimationFrame(() => {
          els.selectedDatePanel.scrollIntoView({ behavior: "smooth", block: "nearest" });
        });
      }
    });

    window.addEventListener("resize", syncSelectedDateMode);
    document.addEventListener("keydown", event => {
      if (event.key === "Escape" && state.selectedDate) clearSelectedDate();
    });
  }

  async function loadScheduleData() {
    if (CONFIG.supabaseUrl && CONFIG.supabaseAnonKey) {
      try {
        const [members, courts, courtUnits, schedules] = await Promise.all([
          fetchTable("members", "id,name,status", "name.asc"),
          fetchTable("courts", "id,name,image,type,location,canonical_name", "name.asc"),
          fetchTable("court_units", "id,court_id,label,surface,sort_order", "sort_order.asc"),
          fetchTable("schedules", "id,date,day,time,title,court_id,court_unit_id,host_id,attendee_ids,regular,closed,important", "date.asc")
        ]);
        return normalizeData({ members, courts, courtUnits, schedules, source: "remote" });
      } catch (error) {
        console.warn("Live schedule unavailable; using the published schedule snapshot.", error);
      }
    }

    const [members, courts, courtUnits, schedules] = await Promise.all([
      fetchJson("../data/members.json"),
      fetchJson("../data/courts.json"),
      fetchJson("../data/court-units.json"),
      fetchJson("../data/schedules.json")
    ]);
    return normalizeData({ members, courts, courtUnits, schedules, source: "snapshot" });
  }

  async function fetchTable(table, select, order) {
    const baseUrl = String(CONFIG.supabaseUrl).replace(/\/$/, "");
    const params = new URLSearchParams({ select, order });
    const response = await fetch(`${baseUrl}/rest/v1/${table}?${params}`, {
      headers: {
        apikey: CONFIG.supabaseAnonKey,
        Accept: "application/json",
        "Accept-Profile": "public"
      },
      cache: "no-store"
    });
    if (!response.ok) throw new Error(`${table} request failed (${response.status})`);
    return response.json();
  }

  async function fetchJson(path) {
    const response = await fetch(path, { cache: "no-store" });
    if (!response.ok) throw new Error(`${path} request failed (${response.status})`);
    return response.json();
  }

  function normalizeData(data) {
    return {
      source: data.source,
      members: data.members.map(row => ({
        id: String(row.id),
        name: row.name,
        status: row.status || "active"
      })),
      courts: data.courts.map(row => ({
        id: String(row.id),
        name: row.name,
        image: row.image || "",
        type: row.type || "",
        location: row.location || "",
        canonicalName: row.canonical_name || row.canonicalName || row.name
      })),
      courtUnits: data.courtUnits.map(row => ({
        id: String(row.id),
        courtId: String(row.court_id || row.courtId || ""),
        label: row.label || "",
        surface: row.surface || "",
        sortOrder: Number(row.sort_order ?? row.sortOrder ?? 0)
      })),
      schedules: data.schedules
        .map(row => ({
          id: String(row.id),
          date: row.date,
          day: row.day || dayName(row.date),
          time: row.time || "시간 미정",
          title: row.title || "테니스 경기",
          courtId: String(row.court_id || row.courtId || ""),
          courtUnitId: String(row.court_unit_id || row.courtUnitId || ""),
          hostId: String(row.host_id || row.hostId || ""),
          attendeeIds: (row.attendee_ids || row.attendeeIds || []).map(String),
          regular: Boolean(row.regular),
          closed: Boolean(row.closed),
          important: Boolean(row.important)
        }))
        .filter(row => DATE_PATTERN.test(row.date || "") && !PRIVATE_COURT_IDS.has(row.courtId))
    };
  }

  function renderAll() {
    renderMonthShell();
    renderCalendar();
    renderSelectedDate();
  }

  function renderMonthShell() {
    els.calendarMonthTitle.textContent = monthLabel(state.month);
    const [year, month] = state.month.split("-").map(Number);
    document.title = `아직도 성장중 · ${year}년 ${month}월 클럽 일정`;
  }

  function renderCalendar() {
    const [year, month] = state.month.split("-").map(Number);
    const firstDay = new Date(year, month - 1, 1).getDay();
    const lastDate = new Date(year, month, 0).getDate();
    const monthSchedules = schedulesForMonth(state.month);
    const schedulesByDate = monthSchedules.reduce((map, schedule) => {
      (map[schedule.date] ||= []).push(schedule);
      return map;
    }, {});

    highlightSelectedWeekday();
    const cells = [];
    for (let index = 0; index < firstDay; index += 1) {
      cells.push('<div class="calendar-placeholder" aria-hidden="true"></div>');
    }

    for (let dateNumber = 1; dateNumber <= lastDate; dateNumber += 1) {
      const date = `${state.month}-${String(dateNumber).padStart(2, "0")}`;
      const weekday = (firstDay + dateNumber - 1) % 7;
      const matches = (schedulesByDate[date] || []).sort(compareSchedules);
      const classes = ["calendar-day"];
      if (weekday === 0) classes.push("is-sunday");
      if (weekday === 6) classes.push("is-saturday");
      if (date < todayIso()) classes.push("is-past");
      if (date === todayIso()) classes.push("is-today");
      if (date === state.selectedDate) classes.push("selected-date");

      const chips = matches.slice(0, 2).map(scheduleChipHtml).join("");
      const overflow = matches.length > 2
        ? `<span class="schedule-chip chip-overflow">+${matches.length - 2} more</span>`
        : "";
      const dots = matches.slice(0, 3).map(schedule => `<span class="calendar-dot ${dotClass(schedule)}"></span>`).join("");
      const matchLabel = matches.length ? `일정 ${matches.length}개` : "일정 없음";

      cells.push(`
        <button class="${classes.join(" ")}" type="button" role="gridcell" data-date="${date}" aria-label="${year}년 ${month}월 ${dateNumber}일, ${matchLabel}" aria-pressed="${date === state.selectedDate}">
          <span class="date-number">${dateNumber}</span>
          <div class="desktop-schedules">${chips}${overflow}</div>
          ${matches.length ? `<div class="mobile-dots" aria-hidden="true">${dots}</div>` : ""}
        </button>`);
    }

    els.calendarGrid.innerHTML = cells.join("");
  }

  function scheduleChipHtml(schedule) {
    const classes = ["schedule-chip", schedule.closed ? "chip-error" : schedule.regular ? "chip-tertiary" : "chip-secondary"];
    if (isSoftTime(schedule.time)) classes.push("time-soft");
    if (schedule.important) classes.push("chip-important");
    const label = `${timeStartLabel(schedule.time)} · ${fullCourtLabel(schedule)}`;
    return `<span class="${classes.join(" ")}" title="${escapeHtml(label)}">${escapeHtml(label)}</span>`;
  }

  function dotClass(schedule) {
    if (schedule.closed) return "dot-closed";
    if (schedule.important) return "dot-important";
    if (schedule.regular) return "dot-regular";
    return isSoftTime(schedule.time) ? "dot-time-soft" : "";
  }

  function highlightSelectedWeekday() {
    const headers = document.querySelectorAll(".weekday-grid > div");
    const selectedIndex = state.selectedDate ? new Date(`${state.selectedDate}T00:00:00`).getDay() : -1;
    headers.forEach((header, index) => {
      header.classList.remove("highlight-sun", "highlight-sat", "highlight-weekday");
      if (index !== selectedIndex) return;
      header.classList.add(index === 0 ? "highlight-sun" : index === 6 ? "highlight-sat" : "highlight-weekday");
    });
  }

  function renderSelectedDate() {
    if (!state.selectedDate) {
      els.selectedDatePanel.hidden = true;
      document.body.classList.remove("selected-date-active");
      return;
    }

    const rows = state.schedules.filter(schedule => schedule.date === state.selectedDate).sort(compareSchedules);
    els.selectedDateTitle.innerHTML = dateLabelHtml(state.selectedDate);
    els.selectedDateList.innerHTML = rows.length
      ? rows.map(scheduleRowHtml).join("")
      : '<div class="empty-state"><div><strong>선택한 날짜에는 일정이 없어요.</strong><span>다른 날짜를 선택해 주세요.</span></div></div>';
    els.selectedDatePanel.hidden = false;
    syncSelectedDateMode();
  }

  function scheduleRowHtml(schedule) {
    const names = attendeeNames(schedule);
    const classes = ["schedule-row"];
    if (!names.length) classes.push("is-empty");
    if (schedule.regular) classes.push("is-regular");
    if (schedule.closed) classes.push("is-closed");
    const iconName = schedule.closed ? "event_busy" : names.length ? "sports_tennis" : "fitness_center";

    return `
      <article class="${classes.join(" ")}">
        <div class="schedule-row-main">
          <div class="schedule-row-icon" aria-hidden="true">
            <span class="material-symbols-outlined">${iconName}</span>
          </div>
          <div class="schedule-row-copy">
            <h3 class="schedule-row-title">${weekendDayTextHtml(schedule.title)}</h3>
            <p class="schedule-row-meta">
              <span class="material-symbols-outlined" aria-hidden="true">schedule</span>
              <span>${escapeHtml(timeRangeLabel(schedule.time))}</span>
              <span aria-hidden="true">@</span>
              <strong>${escapeHtml(fullCourtLabel(schedule))}</strong>
            </p>
          </div>
        </div>
        <div class="schedule-attendees">
          <span class="material-symbols-outlined" aria-hidden="true">group</span>
          <span class="attendee-list">${attendeeListHtml(names)}</span>
        </div>
      </article>`;
  }

  function attendeeListHtml(names) {
    if (!names.length) return "참석자 없음";
    return names.map((name, index) => {
      const genderClass = MALE_MEMBER_NAMES.has(name) ? "male" : "female";
      const separator = index < names.length - 1 ? '<span class="attendee-separator">, </span>' : "";
      return `<span class="attendee-name ${genderClass}">${escapeHtml(name)}</span>${separator}`;
    }).join("");
  }

  function renderLoadError() {
    els.calendarGrid.innerHTML = '<div class="load-error"><div><strong>일정을 불러오지 못했어요.</strong><span>인터넷 연결을 확인한 뒤 다시 시도해 주세요.</span></div></div>';
    els.selectedDatePanel.hidden = true;
    document.body.classList.remove("selected-date-active");
  }

  function changeMonth(delta) {
    const [year, month] = state.month.split("-").map(Number);
    const next = new Date(year, month - 1 + delta, 1);
    state.month = `${next.getFullYear()}-${String(next.getMonth() + 1).padStart(2, "0")}`;
    state.selectedDate = "";
    syncUrlState();
    renderMonthShell();
    renderCalendar();
    renderSelectedDate();
  }

  function clearSelectedDate() {
    state.selectedDate = "";
    syncUrlState();
    renderCalendar();
    renderSelectedDate();
  }

  function syncSelectedDateMode() {
    document.body.classList.toggle("selected-date-active", Boolean(state.selectedDate && window.innerWidth < 768));
  }

  function syncUrlState() {
    const url = new URL(window.location.href);
    url.searchParams.set("month", state.month);
    if (state.selectedDate) url.searchParams.set("date", state.selectedDate);
    else url.searchParams.delete("date");
    url.searchParams.delete("match");
    window.history.replaceState(null, "", url);
  }

  async function shareContent(payload) {
    try {
      if (navigator.share) {
        await navigator.share(payload);
        return;
      }
      await navigator.clipboard.writeText(`${payload.title}\n${payload.text}\n${payload.url}`);
      showToast("공유할 내용이 복사되었습니다.");
    } catch (error) {
      if (error?.name === "AbortError") return;
      try {
        await navigator.clipboard.writeText(payload.url);
        showToast("링크가 복사되었습니다.");
      } catch {
        showToast("브라우저 메뉴에서 링크를 공유해 주세요.");
      }
    }
  }

  function showToast(message) {
    window.clearTimeout(toastTimer);
    els.toast.textContent = message;
    els.toast.classList.add("is-visible");
    toastTimer = window.setTimeout(() => els.toast.classList.remove("is-visible"), 2200);
  }

  function setSyncStatus(label, status) {
    els.syncLabel.textContent = label;
    const container = els.syncLabel.closest(".sync-note");
    container.classList.toggle("is-live", status === "live");
    container.classList.toggle("is-error", status === "error");
  }

  function schedulesForMonth(month) {
    return state.schedules.filter(schedule => schedule.date.startsWith(`${month}-`));
  }

  function courtFor(schedule) {
    return state.courts.find(court => court.id === schedule.courtId) || null;
  }

  function courtUnitFor(schedule) {
    return state.courtUnits.find(unit => unit.id === schedule.courtUnitId) || null;
  }

  function attendeeNames(schedule) {
    return schedule.attendeeIds
      .map(id => state.members.find(member => member.id === id)?.name)
      .filter(Boolean);
  }

  function fullCourtLabel(schedule) {
    const court = courtFor(schedule);
    const unit = courtUnitFor(schedule);
    const unitLabel = unit?.label ? (/^\d+$/.test(unit.label) ? `${unit.label}번 코트` : unit.label) : "";
    return [court?.name, unitLabel].filter(Boolean).join(" · ") || "장소 미정";
  }

  function compareSchedules(a, b) {
    return a.date.localeCompare(b.date) || startMinutes(a.time) - startMinutes(b.time) || a.id.localeCompare(b.id, "ko", { numeric: true });
  }

  function startMinutes(time) {
    const match = String(time).match(/(오전|오후)\s*(\d{1,2}):(\d{2})/);
    if (!match) return 0;
    let hour = Number(match[2]);
    if (match[1] === "오전" && hour === 12) hour = 0;
    if (match[1] === "오후" && hour !== 12) hour += 12;
    return hour * 60 + Number(match[3]);
  }

  function isSoftTime(time) {
    const minutes = startMinutes(time);
    return minutes >= 6 * 60 && minutes < 18 * 60;
  }

  function timeRangeLabel(time) {
    const parts = String(time).match(/(오전|오후)\s*\d{1,2}:\d{2}/g);
    if (!parts?.length) return String(time || "시간 미정");
    const labels = parts.map(toTwentyFourHour);
    return labels.length > 1 ? `${labels[0]}–${labels[1]}` : labels[0];
  }

  function timeStartLabel(time) {
    const parts = String(time).match(/(오전|오후)\s*\d{1,2}:\d{2}/g);
    return parts?.length ? toTwentyFourHour(parts[0]) : String(time || "시간 미정");
  }

  function toTwentyFourHour(value) {
    const match = String(value).match(/(오전|오후)\s*(\d{1,2}):(\d{2})/);
    if (!match) return value;
    let hour = Number(match[2]);
    if (match[1] === "오전" && hour === 12) hour = 0;
    if (match[1] === "오후" && hour !== 12) hour += 12;
    return `${String(hour).padStart(2, "0")}:${match[3]}`;
  }

  function todayIso() {
    const now = new Date();
    return `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, "0")}-${String(now.getDate()).padStart(2, "0")}`;
  }

  function initialMonth() {
    const value = new URLSearchParams(window.location.search).get("month") || "";
    return MONTH_PATTERN.test(value) ? value : todayIso().slice(0, 7);
  }

  function initialDate() {
    const value = new URLSearchParams(window.location.search).get("date") || "";
    return DATE_PATTERN.test(value) ? value : "";
  }

  function dayName(dateValue) {
    return ["일", "월", "화", "수", "목", "금", "토"][new Date(`${dateValue}T00:00:00`).getDay()];
  }

  function monthLabel(monthValue) {
    const [year, month] = monthValue.split("-").map(Number);
    const englishMonth = new Date(year, month - 1, 1).toLocaleDateString("en-US", { month: "short" });
    return `${englishMonth}. ${year}`;
  }

  function dateLabelHtml(dateValue) {
    const [, month, date] = dateValue.split("-");
    const day = dayName(dateValue);
    const dayClass = day === "토" ? "weekend-sat" : day === "일" ? "weekend-sun" : "";
    return `${Number(month)}월 ${Number(date)}일 <span class="${dayClass}">(${day})</span>`;
  }

  function weekendDayTextHtml(value) {
    return escapeHtml(value).replace(/\((토|일)\)/g, (_, day) => `<span class="${day === "토" ? "weekend-sat" : "weekend-sun"}">(${day})</span>`);
  }

  function cleanPageUrl() {
    const url = new URL(window.location.href);
    url.search = "";
    url.hash = "";
    return url.href;
  }

  function escapeHtml(value) {
    return String(value ?? "").replace(/[&<>'"]/g, character => ({
      "&": "&amp;", "<": "&lt;", ">": "&gt;", "'": "&#39;", '"': "&quot;"
    })[character]);
  }
})();

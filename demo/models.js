// Add the model picker without duplicating the compact canvas viewer script.
window.addEventListener('load', async () => {
  const prompt = document.querySelector('#prompt');
  const form = prompt?.closest('.promptbox');
  if (!prompt || !form) return;
  const models = await fetch('/api/models').then(r => r.json());
  const label = document.createElement('label');
  label.htmlFor = 'motionModel'; label.textContent = 'Motion model';
  const select = document.createElement('select');
  select.id = 'motionModel';
  for (const model of models) {
    const option = document.createElement('option');
    option.value = model.id;
    option.disabled = !model.available;
    option.textContent = `${model.label}${model.available ? '' : ' — coming soon'}`;
    select.append(option);
  }
  const hint = document.createElement('div'); hint.className = 'hint';
  const update = () => {
    const model = models.find(item => item.id === select.value);
    hint.textContent = model.available
      ? `${model.skeleton} · ${model.upstream}`
      : `${model.skeleton} · ${model.reason}`;
  };
  select.onchange = update;
  form.insertBefore(label, prompt); form.insertBefore(select, prompt); form.insertBefore(hint, prompt);
  update();

  const nativeFetch = window.fetch.bind(window);
  window.fetch = (input, init) => {
    if (typeof input === 'string' && input.endsWith('/api/generate') && init?.body) {
      const body = JSON.parse(init.body);
      body.model = select.value;
      return nativeFetch(input, {...init, body: JSON.stringify(body)});
    }
    return nativeFetch(input, init);
  };
});

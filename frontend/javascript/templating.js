export const insert = (parent, slotName, content) => {
  const slot = parent.querySelector(`[data-slot="${slotName}"]`);
  slot.append(content);
};

export const grab = (parent, partName) => parent.querySelector(`[data-handle="${partName}"]`);

// format strings like "My name is {{ name }}, I am {{ age }} years old."
export const format = (template, values) => {
  return template.replace(/{{\s*(.*?)\s*}}/g, (_, key) => values[key]);
};

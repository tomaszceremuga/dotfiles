import { useState, useEffect } from "react";
import TextElement from "~/components/TextElement";
import { Search } from 'lucide-react';



type ClipboardItem = {
  value: string;
  type: "text" | "img" | "file" | "code";
}

export default function Home() {

  const [elementsArray, setElementsArray] = useState<ClipboardItem[]>([{ type: "text", value: "wartosc" }]);
  const [selectedItem, setSelectedItem] = useState(0);
  const [searchInputValue, setSearchInputValue] = useState("")


  useEffect(() => {

    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === 'ArrowUp' || e.key === 'k') handleUp();
      if (e.key === 'ArrowDown' || e.key === 'j') handleDown();
      if (e.key === 'Enter') handleEnter();
    };

    window.addEventListener('keydown', handleKeyDown);

    window.addEventListener('wheel', (e: WheelEvent) => {
      if (e.deltaY < 0) handleUp();
      if (e.deltaY > 0) handleDown();
    });

    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [selectedItem]);

  const handleUp = () => {
    if (selectedItem != 0) setSelectedItem(selectedItem - 1);
  }

  const handleDown = () => {
    if (selectedItem != elementsArray.length - 1) setSelectedItem(selectedItem + 1);
  }

  const handleEnter = () => {
    console.log("enter")
  }

  const setBorder = (index: number): string => {
    let borderClass = "px-[9px]";

    if (index === selectedItem) {
      if (index === 0) {
        borderClass = `border-t border-x mt-[-1px] ${elementsArray.length == 1 ? "border-b bg-red-200" : "bg-blue-500"}`;
      } else if (index === elementsArray.length - 1) {
        borderClass = "border-b border-x";
      } else {
        borderClass = "border-x";
      }
    }

    return borderClass;
  }

  return (
    <>
      <div
        className="w-[250px] h-[350px] bg-[#fbf1c7]  text-[#3c3836] p-[20px] selection:bg-[#928374]"
        style={{ fontFamily: 'Iosevka Nerd Font' }}
      >

        <div className="flex items-center mb-4">
          <Search className={`w-4 ${(searchInputValue == "") && "text-[#9b947e]"}`} />
          <input
            type="text"
            placeholder="Search..."
            className="w-2/3  pl-2 border-none focus:outline-none focus:ring-0"
            onChange={(e) => setSearchInputValue(e.target.value)}
          />
        </div>

        <ul className="divide-y divide-[#3c3836] pt-[1px]">
          {elementsArray.map((element: ClipboardItem, index: number) => {
            let borderClass = "px-[9px]";

            if (index === selectedItem) {
              if (index === 0) {
                borderClass = `border-t border-x mt-[-1px] ${elementsArray.length == 1 && "border-b"}`;

              } else if (index === elementsArray.length - 1) {
                borderClass = "border-b border-x";
              } else {
                borderClass = "border-x";
              }
            }

            return (
              <li className={`p-2 ${borderClass}`} key={index}>
                {element.value}
              </li>
            )
          })}
        </ul>

      </div>
    </>
  );
}

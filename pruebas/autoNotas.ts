interface LinkPreview {
    url: string
    title?: string
    description?: string
    image?: string
    siteName?: string
}

type Folder = {
    id: string;
    parentId?: string; // si no existe → folder raíz
    title: string;
    tags: string[];
    description?: string;
    image?: string;
    createdAt: number;
    updatedAt?: number;
    isFavorite?: boolean;
};


type Note = {
    id: string;
    folderId: string;
    title: string;
    link: LinkPreview;
    tags: string[];
    createdAt: number;
    updatedAt?: number;
    isFavorite?: boolean;
};
type SortType =
  | 'date_desc'
  | 'date_asc'
  | 'title_asc'
  | 'title_desc'
  | 'favorite';

type Pagination = {
  page: number;
  limit: number;
  sort: SortType;
};

type IsSucces = {
  ok: boolean;
  message?: string;
  action?: 'RETRY' | 'LOGIN' | 'NONE';
};


interface NotesManager {
  // folders
  getFolders(pagination: Pagination): Folder[];
  getSubFolders(folderId: string): Folder[];
  saveFolder(folder: Folder): IsSucces;
  deleteFolder(id: string): IsSucces;

  // notes
  getNotes(folderId: string, pagination: Pagination): Note[];
  getNoteById(id: string): Note;
  saveNote(note: Note): IsSucces;
  deleteNote(id: string): IsSucces;

  // search
  getNotesByTags(tags: string[]): Note[];
  getFoldersByTags(tags: string[]): Folder[];
}

